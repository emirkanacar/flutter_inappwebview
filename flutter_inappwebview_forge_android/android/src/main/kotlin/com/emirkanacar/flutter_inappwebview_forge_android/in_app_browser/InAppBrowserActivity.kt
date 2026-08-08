package com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser;

import android.annotation.SuppressLint
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.webkit.WebView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.SearchView;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.view.menu.MenuBuilder;
import androidx.appcompat.widget.Toolbar;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;

import com.emirkanacar.flutter_inappwebview_forge_android.R;
import com.emirkanacar.flutter_inappwebview_forge_android.Util;
import com.emirkanacar.flutter_inappwebview_forge_android.find_interaction.FindInteractionController;
import com.emirkanacar.flutter_inappwebview_forge_android.pull_to_refresh.PullToRefreshChannelDelegate;
import com.emirkanacar.flutter_inappwebview_forge_android.pull_to_refresh.PullToRefreshLayout;
import com.emirkanacar.flutter_inappwebview_forge_android.pull_to_refresh.PullToRefreshSettings;
import com.emirkanacar.flutter_inappwebview_forge_android.types.AndroidResource;
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable;
import com.emirkanacar.flutter_inappwebview_forge_android.types.InAppBrowserMenuItem;
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLRequest;
import com.emirkanacar.flutter_inappwebview_forge_android.types.UserScript;
import com.emirkanacar.flutter_inappwebview_forge_android.webview.WebViewChannelDelegate;
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView;
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebViewSettings;

import java.io.IOException
import java.util.HashMap

import io.flutter.plugin.common.MethodChannel

open class InAppBrowserActivity : AppCompatActivity(), InAppBrowserDelegate, Disposable {
  companion object {
    @JvmField
    protected val LOG_TAG = "InAppBrowserActivity"

    @JvmField
    val METHOD_CHANNEL_NAME_PREFIX = "com.emirkanacar/flutter_inappbrowser_"
  }

  @JvmField
  var windowId: Int? = null

  @JvmField
  var id: String = ""

  @JvmField
  var webView: InAppWebView? = null

  @JvmField
  var pullToRefreshLayout: PullToRefreshLayout? = null

  @JvmField
  var actionBar: ActionBar? = null

  @JvmField
  var toolbar: Toolbar? = null

  @JvmField
  var menu: Menu? = null

  @JvmField
  var searchView: SearchView? = null

  @JvmField
  var customSettings = InAppBrowserSettings()

  @JvmField
  var progressBar: ProgressBar? = null

  @JvmField
  var isHidden = false

  @JvmField
  var fromActivity: String? = null

  private val activityResultListeners = ArrayList<ActivityResultListener>()

  @JvmField
  var manager: InAppBrowserManager? = null

  @JvmField
  var channelDelegate: InAppBrowserChannelDelegate? = null

  @JvmField
  var menuItems: MutableList<InAppBrowserMenuItem> = ArrayList()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val bundle = intent.extras
    if (bundle == null) {
      if (savedInstanceState != null) finish()
      return
    }

    id = bundle.getString("id") ?: ""
    val managerId = bundle.getString("managerId")
    val currentManager = InAppBrowserManager.shared[managerId]
    val plugin = currentManager?.plugin
    if (currentManager == null || plugin == null || plugin.messenger == null) {
      if (savedInstanceState != null) finish()
      return
    }
    manager = currentManager

    @Suppress("UNCHECKED_CAST")
    val settingsMap = bundle.getSerializable("settings") as? MutableMap<String, Any?> ?: hashMapOf()
    customSettings.parse(settingsMap)
    windowId = bundle.getInt("windowId")

    setContentView(R.layout.activity_web_view)
    // Android 15 enforces edge-to-edge and disables legacy status-bar color
    // APIs. WindowCompat and the toolbar inset listener provide the supported
    // system-bar behavior across the supported Android range.
    WindowCompat.setDecorFitsSystemWindows(window, false)
    toolbar = findViewById(R.id.toolbar)
    setSupportActionBar(toolbar)

    toolbar?.let { currentToolbar ->
      ViewCompat.setOnApplyWindowInsetsListener(currentToolbar) { view, insets ->
        val systemBars = insets.getInsets(WindowInsetsCompat.Type.statusBars())
        view.setPadding(view.paddingLeft, systemBars.top, view.paddingRight, view.paddingBottom)
        insets
      }
    }

    @Suppress("UNCHECKED_CAST")
    val pullToRefreshInitialSettings = bundle.getSerializable("pullToRefreshInitialSettings") as? MutableMap<String, Any?>
    val pullToRefreshLayoutChannel = MethodChannel(
      plugin.requireMessenger(),
      PullToRefreshLayout.METHOD_CHANNEL_NAME_PREFIX + id
    )
    val pullToRefreshSettings = PullToRefreshSettings()
    pullToRefreshSettings.parse(pullToRefreshInitialSettings ?: hashMapOf())
    val currentPullToRefreshLayout = findViewById<PullToRefreshLayout>(R.id.pullToRefresh)
    pullToRefreshLayout = currentPullToRefreshLayout
    currentPullToRefreshLayout.channelDelegate = PullToRefreshChannelDelegate(
      currentPullToRefreshLayout,
      pullToRefreshLayoutChannel
    )
    currentPullToRefreshLayout.settings = pullToRefreshSettings
    currentPullToRefreshLayout.prepare()

    val currentWebView = findViewById<InAppWebView>(R.id.webView)
    webView = currentWebView
    currentWebView.id = id
    if (windowId != null && windowId != -1) {
      currentWebView.windowId = windowId
    }
    currentWebView.inAppBrowserDelegate = this
    currentWebView.plugin = plugin

    val findInteractionController = FindInteractionController(currentWebView, plugin, id, null)
    currentWebView.findInteractionController = findInteractionController
    findInteractionController.prepare()

    val channel = MethodChannel(plugin.requireMessenger(), METHOD_CHANNEL_NAME_PREFIX + id)
    channelDelegate = InAppBrowserChannelDelegate(channel)
    currentWebView.channelDelegate = WebViewChannelDelegate(currentWebView, channel)

    fromActivity = bundle.getString("fromActivity")
    @Suppress("UNCHECKED_CAST")
    val contextMenu = bundle.getSerializable("contextMenu") as? MutableMap<String, Any?>
    @Suppress("UNCHECKED_CAST")
    val initialUserScripts = bundle.getSerializable("initialUserScripts") as? List<MutableMap<String, Any?>>
    @Suppress("UNCHECKED_CAST")
    val menuItemList = bundle.getSerializable("menuItems") as? List<MutableMap<String, Any?>>
    for (menuItem in menuItemList ?: emptyList()) {
      InAppBrowserMenuItem.fromMap(menuItem)?.let(menuItems::add)
    }

    val webViewSettings = InAppWebViewSettings()
    webViewSettings.parse(settingsMap)
    currentWebView.customSettings = webViewSettings
    currentWebView.contextMenu = contextMenu

    val userScripts = ArrayList<UserScript>()
    initialUserScripts?.forEach { initialUserScript ->
      UserScript.fromMap(initialUserScript)?.let(userScripts::add)
    }
    currentWebView.setInitialUserOnlyScripts(userScripts)

    actionBar = supportActionBar
    prepareView()

    currentWebView.post {
      val currentWindowId = windowId
      if (currentWindowId != null && currentWindowId != -1) {
        val currentPlugin = currentWebView.plugin
        val message = currentPlugin?.inAppWebViewManager?.windowWebViewMessages?.get(currentWindowId)
        if (message != null) {
          (message.obj as? WebView.WebViewTransport)?.setWebView(currentWebView)
          message.sendToTarget()
        }
        // Window-id WebViews skip initial script registration until the transport is attached.
        currentWebView.post {
          if (currentWebView.plugin != null) {
            currentWebView.prepareAndAddUserScripts()
          }
        }
      } else {
        val initialFile = bundle.getString("initialFile")
        @Suppress("UNCHECKED_CAST")
        val initialUrlRequest = bundle.getSerializable("initialUrlRequest") as? MutableMap<String, Any?>
        val initialData = bundle.getString("initialData")
        if (initialFile != null) {
          try {
            currentWebView.loadFile(initialFile)
          } catch (e: IOException) {
            Log.e(LOG_TAG, "$initialFile asset file cannot be found!", e)
            return@post
          }
        } else if (initialData != null) {
          currentWebView.loadDataWithBaseURL(
            bundle.getString("initialBaseUrl"),
            initialData,
            bundle.getString("initialMimeType"),
            bundle.getString("initialEncoding"),
            bundle.getString("initialHistoryUrl")
          )
        } else {
          URLRequest.fromMap(initialUrlRequest)?.let(currentWebView::loadUrl)
        }
      }
      channelDelegate?.onBrowserCreated()
    }
  }

  private fun prepareView() {
    webView?.prepare()

    if (customSettings.hidden == true) hide() else show()

    progressBar = findViewById(R.id.progressBar)
    progressBar?.max = if (customSettings.hideProgressBar == true) 0 else 100

    actionBar?.let { currentActionBar ->
      currentActionBar.setDisplayShowTitleEnabled(customSettings.hideTitleBar != true)
      if (customSettings.hideToolbarTop == true) currentActionBar.hide()
      customSettings.toolbarTopBackgroundColor?.takeIf { it.isNotEmpty() }?.let {
        currentActionBar.setBackgroundDrawable(ColorDrawable(Color.parseColor(it)))
      }
      customSettings.toolbarTopFixedTitle?.takeIf { it.isNotEmpty() }?.let(currentActionBar::setTitle)
    }
  }

  @SuppressLint("RestrictedApi")
  override fun onCreateOptionsMenu(m: Menu): Boolean {
    menu = m
    if (customSettings.toolbarTopFixedTitle.isNullOrEmpty()) {
      actionBar?.title = webView?.title ?: ""
    }

    val currentMenu = menu ?: return super.onCreateOptionsMenu(m)
    (currentMenu as? MenuBuilder)?.setOptionalIconsVisible(true)

    try {
      menuInflater.inflate(R.menu.menu_main, currentMenu)
    } catch (e: Exception) {
      e.printStackTrace()
      Log.e(
        LOG_TAG,
        "Cannot inflate com.emirkanacar.flutter_inappwebview_forge_android.R.menu.menu_main." +
          "To make it work, you need to set minifyEnabled false and shrinkResources false in your build.gradle file."
      )
      return super.onCreateOptionsMenu(m)
    }

    currentMenu.findItem(R.id.menu_search)?.let { menuSearchItem ->
      if (customSettings.hideUrlBar == true) menuSearchItem.isVisible = false
      searchView = menuSearchItem.actionView as? SearchView
      searchView?.let { currentSearchView ->
        currentSearchView.isFocusable = true
        currentSearchView.setQuery(webView?.url ?: "", false)
        currentSearchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
          override fun onQueryTextSubmit(query: String): Boolean {
            if (query.isEmpty()) return false
            webView?.loadUrl(query)
            currentSearchView.setQuery("", false)
            currentSearchView.isIconified = true
            return true
          }

          override fun onQueryTextChange(newText: String): Boolean = false
        })
        currentSearchView.setOnCloseListener {
          if (currentSearchView.query.toString().isEmpty()) {
            currentSearchView.setQuery(webView?.url ?: "", false)
          }
          false
        }
        currentSearchView.setOnQueryTextFocusChangeListener { _, hasFocus ->
          if (!hasFocus) {
            currentSearchView.setQuery("", false)
            currentSearchView.isIconified = true
          }
        }
      }
    }

    if (customSettings.hideDefaultMenuItems == true) {
      listOf(
        R.id.action_close,
        R.id.action_go_back,
        R.id.action_reload,
        R.id.action_go_forward,
        R.id.action_share
      ).forEach { itemId ->
        currentMenu.findItem(itemId)?.isVisible = false
      }
    }

    for (menuItem in menuItems) {
      val item = currentMenu.add(Menu.NONE, menuItem.id, menuItem.order ?: Menu.NONE, menuItem.title)
      if (menuItem.isShowAsAction) item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
      when (val icon = menuItem.icon) {
        is AndroidResource -> item.setIcon(icon.getIdentifier(this))
        is ByteArray -> item.setIcon(Util.drawableFromBytes(this, icon))
      }
      menuItem.iconColor?.takeIf {
        it.isNotEmpty() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP
      }?.let { iconColor ->
        item.icon?.setTint(Color.parseColor(iconColor))
      }
      item.setOnMenuItemClickListener {
        channelDelegate?.onMenuItemClicked(menuItem)
        true
      }
    }

    return true
  }

  override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
    if (keyCode == KeyEvent.KEYCODE_BACK) {
      if (customSettings.shouldCloseOnBackButtonPressed == true) {
        close()
        return true
      }
      if (customSettings.allowGoBackWithBackButton == true) {
        if (canGoBack()) {
          goBack()
        } else if (customSettings.closeOnCannotGoBack == true) {
          close()
        }
        return true
      }
      if (customSettings.shouldCloseOnBackButtonPressed != true) {
        return true
      }
    }
    return super.onKeyDown(keyCode, event)
  }

  @JvmOverloads
  fun close(result: MethodChannel.Result? = null) {
    channelDelegate?.onExit()

    dispose()

    result?.success(true)
  }

  fun reload() {
    webView?.reload()
  }

  fun goBack() {
    if (canGoBack()) {
      webView?.goBack()
    }
  }

  fun canGoBack(): Boolean {
    return webView?.canGoBack() == true
  }

  fun goForward() {
    if (canGoForward()) {
      webView?.goForward()
    }
  }

  fun canGoForward(): Boolean {
    return webView?.canGoForward() == true
  }

  fun hide() {
    fromActivity?.let { activityName ->
      try {
        isHidden = true
        val openActivity = Intent(this, Class.forName(activityName))
        openActivity.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        startActivityIfNeeded(openActivity, 0)
      } catch (e: ClassNotFoundException) {
        Log.d(LOG_TAG, "", e)
      }
    }
  }

  fun show() {
    isHidden = false
    val openActivity = Intent(this, InAppBrowserActivity::class.java)
    openActivity.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
    startActivityIfNeeded(openActivity, 0)
  }

  fun goBackButtonClicked(item: MenuItem) {
    goBack()
  }

  fun goForwardButtonClicked(item: MenuItem) {
    goForward()
  }

  fun shareButtonClicked(item: MenuItem) {
    val share = Intent(Intent.ACTION_SEND)
    share.type = "text/plain"
    share.putExtra(Intent.EXTRA_TEXT, webView?.url ?: "")
    startActivity(Intent.createChooser(share, "Share"))
  }

  fun reloadButtonClicked(item: MenuItem) {
    reload()
  }

  fun closeButtonClicked(item: MenuItem) {
    close()
  }

  fun setSettings(newSettings: InAppBrowserSettings, newSettingsMap: HashMap<String, Any?>) {
    val newInAppWebViewSettings = InAppWebViewSettings()
    newInAppWebViewSettings.parse(newSettingsMap)
    webView?.setSettings(newInAppWebViewSettings, newSettingsMap)

    if (newSettingsMap["hidden"] != null && customSettings.hidden != newSettings.hidden) {
      if (newSettings.hidden == true) {
        hide()
      } else {
        show()
      }
    }

    if (newSettingsMap["hideProgressBar"] != null &&
      customSettings.hideProgressBar != newSettings.hideProgressBar) {
      progressBar?.max = if (newSettings.hideProgressBar == true) 0 else 100
    }

    if (newSettingsMap["hideTitleBar"] != null &&
      customSettings.hideTitleBar != newSettings.hideTitleBar) {
      actionBar?.setDisplayShowTitleEnabled(newSettings.hideTitleBar != true)
    }

    if (newSettingsMap["hideToolbarTop"] != null &&
      customSettings.hideToolbarTop != newSettings.hideToolbarTop) {
      if (newSettings.hideToolbarTop == true) {
        actionBar?.hide()
      } else {
        actionBar?.show()
      }
    }

    if (newSettingsMap["toolbarTopBackgroundColor"] != null &&
      !Util.objEquals(customSettings.toolbarTopBackgroundColor, newSettings.toolbarTopBackgroundColor) &&
      !newSettings.toolbarTopBackgroundColor.isNullOrEmpty()) {
      actionBar?.setBackgroundDrawable(
        ColorDrawable(Color.parseColor(newSettings.toolbarTopBackgroundColor))
      )
    }

    if (newSettingsMap["toolbarTopFixedTitle"] != null &&
      !Util.objEquals(customSettings.toolbarTopFixedTitle, newSettings.toolbarTopFixedTitle) &&
      !newSettings.toolbarTopFixedTitle.isNullOrEmpty()) {
      actionBar?.title = newSettings.toolbarTopFixedTitle
    }

    if (newSettingsMap["hideUrlBar"] != null &&
      customSettings.hideUrlBar != newSettings.hideUrlBar) {
      menu?.findItem(R.id.menu_search)?.isVisible = newSettings.hideUrlBar != true
    }

    if (newSettingsMap["hideDefaultMenuItems"] != null &&
      customSettings.hideDefaultMenuItems != newSettings.hideDefaultMenuItems) {
      val visibility = newSettings.hideDefaultMenuItems != true
      menu?.findItem(R.id.action_close)?.isVisible = visibility
      menu?.findItem(R.id.action_go_back)?.isVisible = visibility
      menu?.findItem(R.id.action_reload)?.isVisible = visibility
      menu?.findItem(R.id.action_go_forward)?.isVisible = visibility
      menu?.findItem(R.id.action_share)?.isVisible = visibility
    }

    customSettings = newSettings
  }

  fun getCustomSettingsMap(): MutableMap<String, Any?>? {
    val webViewSettingsMap = webView?.getCustomSettingsMap() ?: return null
    return customSettings.getRealSettings(this).apply {
      putAll(webViewSettingsMap)
    }
  }

  override fun getActivity(): Activity {
    return this
  }

  override fun didChangeTitle(title: String) {
    if (customSettings.toolbarTopFixedTitle.isNullOrEmpty()) {
      actionBar?.title = title
    }
  }

  override fun didStartNavigation(url: String) {
    progressBar?.progress = 0
    searchView?.setQuery(url, false)
  }

  override fun didUpdateVisitedHistory(url: String) {
    searchView?.setQuery(url, false)
  }

  override fun didFinishNavigation(url: String) {
    searchView?.setQuery(url, false)
    progressBar?.progress = 0
  }

  override fun didFailNavigation(url: String, errorCode: Int, description: String) {
    progressBar?.progress = 0
  }

  override fun didChangeProgress(progress: Int) {
    progressBar?.let { currentProgressBar ->
      currentProgressBar.visibility = View.VISIBLE
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        currentProgressBar.setProgress(progress, true)
      } else {
        currentProgressBar.progress = progress
      }
      if (progress == 100) {
        currentProgressBar.visibility = View.GONE
      }
    }
  }

  override fun getActivityResultListeners(): MutableList<ActivityResultListener> {
    return activityResultListeners
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    for (listener in activityResultListeners.toList()) {
      if (listener.onActivityResult(requestCode, resultCode, data)) {
        return
      }
    }
    super.onActivityResult(requestCode, resultCode, data)
  }

  override fun dispose() {
    channelDelegate?.dispose()
    channelDelegate = null
    activityResultListeners.clear();
    webView?.let { currentWebView ->
      manager?.plugin?.activityPluginBinding?.let { binding ->
        currentWebView.inAppWebViewChromeClient?.let { chromeClient ->
          binding.removeActivityResultListener(chromeClient)
        }
      }
      findViewById<RelativeLayout>(R.id.container)?.removeAllViews()
      currentWebView.dispose()
      webView = null;
      finish()
    }
  }

  override fun onDestroy() {
    dispose()
    super.onDestroy()
  }
}
