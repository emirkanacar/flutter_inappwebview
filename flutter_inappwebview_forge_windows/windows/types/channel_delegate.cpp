#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>

#include <exception>
#include <memory>
#include <string>

#include "../utils/log.h"
#include "../utils/util.h"
#include "channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  ChannelDelegate::ChannelDelegate(flutter::BinaryMessenger* messenger, const std::string& name) : messenger(messenger)
  {
    channel = std::make_shared<flutter::MethodChannel<flutter::EncodableValue>>(
      this->messenger, name,
      &flutter::StandardMethodCodec::GetInstance()
    );
    channel->SetMethodCallHandler(
      [this](const auto& call, auto result)
      {
        this->HandleMethodCallGuarded(call, std::move(result));
      });
  }

  void ChannelDelegate::HandleMethodCallGuarded(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    // Handlers read arguments with get_fl_map_value, which throws
    // std::out_of_range or std::bad_variant_access when an argument is missing
    // or has an unexpected type. An exception escaping this callback would
    // terminate the process, so complete the call with an error instead.
    // The original result is shared with a forwarding result so it can still
    // be completed after the handler has taken ownership of the forwarder.
    std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> sharedResult = std::move(result);
    auto completed = std::make_shared<bool>(false);
    auto forwardingResult = std::make_unique<flutter::MethodResultFunctions<flutter::EncodableValue>>(
      [sharedResult, completed](const flutter::EncodableValue* value)
      {
        *completed = true;
        sharedResult->Success(value ? *value : flutter::EncodableValue());
      },
      [sharedResult, completed](const std::string& code, const std::string& message, const flutter::EncodableValue* details)
      {
        *completed = true;
        sharedResult->Error(code, message, details ? *details : flutter::EncodableValue());
      },
      [sharedResult, completed]()
      {
        *completed = true;
        sharedResult->NotImplemented();
      });

    std::string errorMessage;
    try {
      HandleMethodCall(method_call, std::move(forwardingResult));
      return;
    }
    catch (const std::exception& e) {
      errorMessage = method_call.method_name() + ": " + e.what();
    }
    catch (...) {
      errorMessage = method_call.method_name() + ": unexpected native exception";
    }

    debugLog(errorMessage, true);
    if (!*completed) {
      *completed = true;
      sharedResult->Error("invalid_arguments", errorMessage);
    }
  }

  void ChannelDelegate::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {}

  void ChannelDelegate::UnregisterMethodCallHandler() const
  {
    if (channel) {
      channel->SetMethodCallHandler(nullptr);
    }
  }

  ChannelDelegate::~ChannelDelegate()
  {
    messenger = nullptr;
    channel.reset();
  }
}