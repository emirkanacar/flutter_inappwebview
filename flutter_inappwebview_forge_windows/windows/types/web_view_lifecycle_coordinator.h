#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_VIEW_LIFECYCLE_COORDINATOR_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_VIEW_LIFECYCLE_COORDINATOR_H_

#include <atomic>
#include <cstdint>

namespace flutter_inappwebview_plugin {

// Internal only: this state is not exposed through the Flutter API.
enum class WebViewLifecycleState {
  creating,
  preparing,
  attached,
  ready,
  detached_retained,
  reattached,
  renderer_lost,
  disposing,
  disposed,
};

class WebViewLifecycleCoordinator {
 public:
  WebViewLifecycleState state() const {
    return state_.load(std::memory_order_acquire);
  }

  bool acceptsCallbacks() const {
    const auto current = state();
    return current != WebViewLifecycleState::disposing &&
           current != WebViewLifecycleState::disposed;
  }

  bool beginDisposal() {
    auto current = state_.load(std::memory_order_acquire);
    while (current != WebViewLifecycleState::disposing &&
           current != WebViewLifecycleState::disposed) {
      if (state_.compare_exchange_weak(
              current, WebViewLifecycleState::disposing,
              std::memory_order_acq_rel, std::memory_order_acquire)) {
        operation_id_.fetch_add(1, std::memory_order_relaxed);
        return true;
      }
    }
    return false;
  }

  void finishDisposal() {
    pending_async_operations_.store(0, std::memory_order_release);
    state_.store(WebViewLifecycleState::disposed, std::memory_order_release);
  }

  uint64_t operationId() const {
    return operation_id_.load(std::memory_order_acquire);
  }

  uint64_t pendingAsyncOperations() const {
    return pending_async_operations_.load(std::memory_order_acquire);
  }

  uint64_t callbackCompletionCount() const {
    return callback_completion_count_.load(std::memory_order_acquire);
  }

  void markDetachedRetained() {
    if (acceptsCallbacks()) {
      state_.store(WebViewLifecycleState::detached_retained,
                   std::memory_order_release);
    }
  }

  bool beginPreparing() {
    if (!acceptsCallbacks()) {
      return false;
    }
    const auto current = state();
    if (current != WebViewLifecycleState::creating &&
        current != WebViewLifecycleState::detached_retained &&
        current != WebViewLifecycleState::reattached) {
      return false;
    }
    state_.store(WebViewLifecycleState::preparing, std::memory_order_release);
    return true;
  }

  void markAttached() {
    if (!acceptsCallbacks()) {
      return;
    }
    const auto current = state();
    if (current == WebViewLifecycleState::detached_retained ||
        current == WebViewLifecycleState::renderer_lost) {
      state_.store(WebViewLifecycleState::reattached,
                   std::memory_order_release);
    } else if (current == WebViewLifecycleState::creating ||
               current == WebViewLifecycleState::preparing) {
      state_.store(WebViewLifecycleState::attached,
                   std::memory_order_release);
    }
  }

  void markReady() {
    if (!acceptsCallbacks()) {
      return;
    }
    const auto current = state();
    if (current == WebViewLifecycleState::attached ||
        current == WebViewLifecycleState::reattached ||
        current == WebViewLifecycleState::preparing) {
      state_.store(WebViewLifecycleState::ready,
                   std::memory_order_release);
    }
  }

  void markReattached() {
    if (acceptsCallbacks()) {
      state_.store(WebViewLifecycleState::reattached,
                   std::memory_order_release);
    }
  }

  bool markRendererLost() {
    if (!acceptsCallbacks()) {
      return false;
    }
    state_.store(WebViewLifecycleState::renderer_lost,
                 std::memory_order_release);
    return true;
  }

  uint64_t beginAsyncOperation() {
    if (!acceptsCallbacks()) {
      return 0;
    }
    pending_async_operations_.fetch_add(1, std::memory_order_relaxed);
    return operation_id_.fetch_add(1, std::memory_order_relaxed) + 1;
  }

  void completeAsyncOperation() {
    auto pending = pending_async_operations_.load(std::memory_order_acquire);
    while (pending > 0 &&
           !pending_async_operations_.compare_exchange_weak(
               pending, pending - 1, std::memory_order_acq_rel,
               std::memory_order_acquire)) {
    }
    if (pending > 0) {
      callback_completion_count_.fetch_add(1, std::memory_order_relaxed);
    }
  }

 private:
  std::atomic<WebViewLifecycleState> state_{WebViewLifecycleState::creating};
  std::atomic<uint64_t> operation_id_{0};
  std::atomic<uint64_t> pending_async_operations_{0};
  std::atomic<uint64_t> callback_completion_count_{0};
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_VIEW_LIFECYCLE_COORDINATOR_H_
