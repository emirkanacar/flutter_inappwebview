package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.widget.RemoteViews;

import androidx.browser.customtabs.CustomTabColorSchemeParams;
import androidx.browser.customtabs.CustomTabsCallback;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.browser.customtabs.CustomTabsService;
import androidx.browser.customtabs.CustomTabsSession;
import androidx.browser.customtabs.EngagementSignalsCallback;
import androidx.annotation.CallSuper

import com.emirkanacar.flutter_inappwebview_forge_android.R;
import com.emirkanacar.flutter_inappwebview_forge_android.Util;
import com.emirkanacar.flutter_inappwebview_forge_android.types.AndroidResource;
import com.emirkanacar.flutter_inappwebview_forge_android.types.CustomTabsActionButton;
import com.emirkanacar.flutter_inappwebview_forge_android.types.CustomTabsMenuItem;
import com.emirkanacar.flutter_inappwebview_forge_android.types.CustomTabsSecondaryToolbar;
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable;

import io.flutter.plugin.common.MethodChannel

open class ChromeCustomTabsActivity : Activity(), Disposable {
  companion object {
    @JvmField
    protected val LOG_TAG = "CustomTabsActivity"

    @JvmField
    val METHOD_CHANNEL_NAME_PREFIX = "com.emirkanacar/flutter_chromesafaribrowser_"

    @JvmField
    val CHROME_CUSTOM_TAB_REQUEST_CODE = 100

    @JvmField
    val NO_HISTORY_CHROME_CUSTOM_TAB_REQUEST_CODE = 101
  }

  @JvmField
  var id: String = ""

  @JvmField
  protected var builder: CustomTabsIntent.Builder? = null

  @JvmField
  var customSettings = ChromeCustomTabsSettings()

  @JvmField
  var customTabActivityHelper = CustomTabActivityHelper()

  @JvmField
  var customTabsSession: CustomTabsSession? = null

  protected var onOpened = false
  protected var onCompletedInitialLoad = false
  protected var isBindSuccess = false

  @JvmField
  var manager: ChromeSafariBrowserManager? = null

  @JvmField
  var initialUrl: String? = null

  @JvmField
  var initialOtherLikelyURLs: List<String>? = null

  @JvmField
  var initialHeaders: Map<String, String>? = null

  @JvmField
  var initialReferrer: String? = null

  @JvmField
  var menuItems: MutableList<CustomTabsMenuItem> = ArrayList()

  @JvmField
  var actionButton: CustomTabsActionButton? = null

  @JvmField
  var secondaryToolbar: CustomTabsSecondaryToolbar? = null

  @JvmField
  var channelDelegate: ChromeCustomTabsChannelDelegate? = null

  @CallSuper
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.chrome_custom_tabs_layout)

    val bundle = intent.extras
    if (bundle == null) {
      if (savedInstanceState != null) close()
      return
    }

    id = bundle.getString("id") ?: ""
    val managerId = bundle.getString("managerId")
    val currentManager = ChromeSafariBrowserManager.shared[managerId]
    val plugin = currentManager?.plugin
    if (currentManager == null || plugin == null || plugin.messenger == null) {
      if (savedInstanceState != null) close()
      return
    }
    manager = currentManager
    currentManager.browsers[id] = this

    val channel = MethodChannel(plugin.requireMessenger(), METHOD_CHANNEL_NAME_PREFIX + id)
    channelDelegate = ChromeCustomTabsChannelDelegate(this, channel)

    initialUrl = bundle.getString("url")
    @Suppress("UNCHECKED_CAST")
    initialHeaders = Util.getValueExtra(bundle, "headers") as? Map<String, String>
    initialReferrer = bundle.getString("referrer")
    initialOtherLikelyURLs = (Util.getValueExtra(bundle, "otherLikelyURLs") as? List<*>)
      ?.filterIsInstance<String>()

    @Suppress("UNCHECKED_CAST")
    val settings = Util.getValueExtra(bundle, "settings") as? MutableMap<String, Any?>
    customSettings = ChromeCustomTabsSettings().parse(settings ?: hashMapOf())
    @Suppress("UNCHECKED_CAST")
    val actionButtonMap = Util.getValueExtra(bundle, "actionButton") as? MutableMap<String, Any?>
    actionButton = CustomTabsActionButton.fromMap(actionButtonMap)
    @Suppress("UNCHECKED_CAST")
    val secondaryToolbarMap = Util.getValueExtra(bundle, "secondaryToolbar") as? MutableMap<String, Any?>
    secondaryToolbar = CustomTabsSecondaryToolbar.fromMap(secondaryToolbarMap)
    @Suppress("UNCHECKED_CAST")
    val menuItemList = Util.getValueExtra(bundle, "menuItemList") as? List<MutableMap<String, Any?>>
    for (menuItem in menuItemList ?: emptyList()) {
      CustomTabsMenuItem.fromMap(menuItem)?.let(menuItems::add)
    }

    if (customSettings.noHistory == true) {
      plugin.noHistoryCustomTabsActivityCallbacks?.noHistoryBrowserIDs?.put(id, id)
    }

    customTabActivityHelper.setConnectionCallback(object : CustomTabActivityHelper.ConnectionCallback {
      override fun onCustomTabsConnected() {
        customTabsConnected()
        channelDelegate?.onServiceConnected()
      }

      override fun onCustomTabsDisconnected() {
        close()
        dispose()
      }
    })

    customTabActivityHelper.setCustomTabsCallback(object : CustomTabsCallback() {
      override fun onNavigationEvent(navigationEvent: Int, extras: Bundle?) {
        if (navigationEvent == TAB_SHOWN && !onOpened) {
          onOpened = true
          channelDelegate?.onOpened()
        }
        if (navigationEvent == NAVIGATION_FINISHED && !onCompletedInitialLoad) {
          onCompletedInitialLoad = true
          channelDelegate?.onCompletedInitialLoad()
        }
        channelDelegate?.onNavigationEvent(navigationEvent)
      }

      override fun extraCallback(callbackName: String, args: Bundle?) = Unit

      override fun onMessageChannelReady(extras: Bundle?) {
        channelDelegate?.onMessageChannelReady()
      }

      override fun onPostMessage(message: String, extras: Bundle?) {
        channelDelegate?.onPostMessage(message)
      }

      override fun onRelationshipValidationResult(
        relation: Int,
        requestedOrigin: Uri,
        result: Boolean,
        extras: Bundle?
      ) {
        channelDelegate?.onRelationshipValidationResult(relation, requestedOrigin, result)
      }
    })
  }

  open fun launchUrl(
    url: String,
    headers: Map<String, String>?,
    referrer: String?,
    otherLikelyURLs: List<String>?
  ) {
    launchUrlWithSession(customTabsSession, url, headers, referrer, otherLikelyURLs)
  }

  fun launchUrlWithSession(
    session: CustomTabsSession?,
    url: String,
    headers: Map<String, String>?,
    referrer: String?,
    otherLikelyURLs: List<String>?
  ) {
    mayLaunchUrl(url, otherLikelyURLs)
    builder = CustomTabsIntent.Builder(session)
    prepareCustomTabs()

    val customTabsIntent = builder?.build() ?: return
    prepareCustomTabsIntent(customTabsIntent)

    CustomTabActivityHelper.openCustomTab(
      this,
      customTabsIntent,
      Uri.parse(url),
      headers?.toMutableMap(),
      referrer?.let(Uri::parse),
      CHROME_CUSTOM_TAB_REQUEST_CODE
    )
  }

  fun mayLaunchUrl(url: String?, otherLikelyURLs: List<String>?): Boolean {
    val uri = url?.let(Uri::parse) ?: return false

    val bundleOtherLikelyURLs = ArrayList<Bundle>()
    if (otherLikelyURLs != null) {
      val bundleOtherLikelyURL = Bundle()
      for (otherLikelyURL in otherLikelyURLs) {
        bundleOtherLikelyURL.putString(CustomTabsService.KEY_URL, otherLikelyURL)
      }
    }
    return customTabActivityHelper.mayLaunchUrl(uri, null, bundleOtherLikelyURLs)
  }

  @CallSuper
  open fun customTabsConnected() {
    customTabsSession = customTabActivityHelper.getSession()

    customTabsSession?.let { session ->
      try {
        val bundle = Bundle()
        if (session.isEngagementSignalsApiAvailable(bundle)) {
          session.setEngagementSignalsCallback(object : EngagementSignalsCallback {
            override fun onVerticalScrollEvent(isDirectionUp: Boolean, extras: Bundle) {
              channelDelegate?.onVerticalScrollEvent(isDirectionUp)
            }

            override fun onGreatestScrollPercentageIncreased(scrollPercentage: Int, extras: Bundle) {
              channelDelegate?.onGreatestScrollPercentageIncreased(scrollPercentage)
            }

            override fun onSessionEnded(didUserInteract: Boolean, extras: Bundle) {
              channelDelegate?.onSessionEnded(didUserInteract)
            }
          }, bundle)
        }
      } catch (e: Throwable) {
        Log.d(LOG_TAG, "Custom Tabs Engagement Signals API not supported", e)
      }
    }

    // avoid webpage reopen if isBindSuccess is false: onServiceConnected->launchUrl
    if (isBindSuccess && initialUrl != null) {
      launchUrl(initialUrl ?: return, initialHeaders, initialReferrer, initialOtherLikelyURLs)
    }
  }

  private fun prepareCustomTabs() {
    val currentBuilder = builder ?: return

    if (customSettings.addDefaultShareMenuItem != null) {
      currentBuilder.setShareState(
        if (customSettings.addDefaultShareMenuItem == true) {
          CustomTabsIntent.SHARE_STATE_ON
        } else {
          CustomTabsIntent.SHARE_STATE_OFF
        }
      )
    } else {
      currentBuilder.setShareState(customSettings.shareState ?: CustomTabsIntent.SHARE_STATE_DEFAULT)
    }

    val defaultColorSchemeBuilder = CustomTabColorSchemeParams.Builder()
    customSettings.toolbarBackgroundColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setToolbarColor(Color.parseColor(it))
    }
    customSettings.navigationBarColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setNavigationBarColor(Color.parseColor(it))
    }
    customSettings.navigationBarDividerColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setNavigationBarDividerColor(Color.parseColor(it))
    }
    customSettings.secondaryToolbarColor?.takeIf { it.isNotEmpty() }?.let {
      defaultColorSchemeBuilder.setSecondaryToolbarColor(Color.parseColor(it))
    }
    currentBuilder.setDefaultColorSchemeParams(defaultColorSchemeBuilder.build())

    currentBuilder.setShowTitle(customSettings.showTitle == true)
    currentBuilder.setUrlBarHidingEnabled(customSettings.enableUrlBarHiding == true)
    currentBuilder.setInstantAppsEnabled(customSettings.instantAppsEnabled == true)
    if (customSettings.startAnimations.size == 2) {
      currentBuilder.setStartAnimations(this,
              customSettings.startAnimations[0].getIdentifier(this),
              customSettings.startAnimations[1].getIdentifier(this))
    }
    if (customSettings.exitAnimations.size == 2) {
      currentBuilder.setExitAnimations(this,
              customSettings.exitAnimations[0].getIdentifier(this),
              customSettings.exitAnimations[1].getIdentifier(this))
    }

    for (menuItem in menuItems) {
      currentBuilder.addMenuItem(menuItem.label, createPendingIntent(menuItem.id))
    }

    actionButton?.let { button ->
      val data = button.icon
      val bitmapOptions = BitmapFactory.Options()
      bitmapOptions.inMutable = true
      val bmp = BitmapFactory.decodeByteArray(data, 0, data.size, bitmapOptions)
      currentBuilder.setActionButton(
        bmp,
        button.description,
        createPendingIntent(button.id),
        button.isShouldTint
      )
    }

    secondaryToolbar?.let { toolbar ->
      val layout = toolbar.layout
      val remoteViews = RemoteViews(layout.defPackage, layout.getIdentifier(this))
      val clickableIDs = IntArray(toolbar.clickableIDs.size)
      for (i in toolbar.clickableIDs.indices) {
        clickableIDs[i] = toolbar.clickableIDs[i].getIdentifier(this)
      }
      currentBuilder.setSecondaryToolbarViews(remoteViews, clickableIDs, getSecondaryToolbarOnClickPendingIntent())
    }
  }

  fun getSecondaryToolbarOnClickPendingIntent(): PendingIntent {
    val broadcastIntent = Intent(this, ActionBroadcastReceiver::class.java)

    val extras = Bundle()
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_VIEW_ID, id)
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_MANAGER_ID, manager?.id)
    broadcastIntent.putExtras(extras)

    if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      return PendingIntent.getBroadcast(
              this, 0, broadcastIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
    } else {
      return PendingIntent.getBroadcast(
              this, 0, broadcastIntent, PendingIntent.FLAG_UPDATE_CURRENT)
    }
  }

  private fun prepareCustomTabsIntent(customTabsIntent: CustomTabsIntent) {
    if (customSettings.packageName != null) {
      customTabsIntent.intent.setPackage(customSettings.packageName)
    } else {
      customTabsIntent.intent.setPackage(CustomTabsHelper.getPackageNameToUse(this))
    }

    if (customSettings.keepAliveEnabled == true) {
      CustomTabsHelper.addKeepAliveExtra(this, customTabsIntent.intent)
    }

    if (customSettings.alwaysUseBrowserUI == true) {
      CustomTabsIntent.setAlwaysUseBrowserUI(customTabsIntent.intent)
    }
  }

  fun updateActionButton(icon: ByteArray, description: String) {
    val session = customTabsSession ?: return
    val button = actionButton ?: return
    val bitmapOptions = BitmapFactory.Options()
    bitmapOptions.inMutable = true
    val bmp = BitmapFactory.decodeByteArray(icon, 0, icon.size, bitmapOptions)
    session.setActionButton(bmp, description)
    button.icon = icon
    button.description = description
  }

  fun updateSecondaryToolbar(secondaryToolbar: CustomTabsSecondaryToolbar) {
    val session = customTabsSession ?: return
    val layout = secondaryToolbar.layout
    val remoteViews = RemoteViews(layout.defPackage, layout.getIdentifier(this))
    val clickableIDs = IntArray(secondaryToolbar.clickableIDs.size)
    for (i in secondaryToolbar.clickableIDs.indices) {
      clickableIDs[i] = secondaryToolbar.clickableIDs[i].getIdentifier(this)
    }
    session.setSecondaryToolbarViews(remoteViews, clickableIDs, getSecondaryToolbarOnClickPendingIntent())
    this.secondaryToolbar = secondaryToolbar
  }

  override fun onStart() {
    super.onStart()
    isBindSuccess = customTabActivityHelper.bindCustomTabsService(this)

    if (!isBindSuccess && initialUrl != null) {
      // chrome process not running, start tab directly
      launchUrlWithSession(null, initialUrl ?: return, initialHeaders, initialReferrer, initialOtherLikelyURLs)
    }
  }

  override fun onStop() {
    super.onStop()
  }

  override fun onDestroy() {
    customTabActivityHelper.unbindCustomTabsService(this)
    isBindSuccess = false
    super.onDestroy()
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    if (requestCode == CHROME_CUSTOM_TAB_REQUEST_CODE) {
      close()
      dispose()
    }
  }

  private fun createPendingIntent(actionSourceId: Int): PendingIntent {
    val actionIntent = Intent(this, ActionBroadcastReceiver::class.java)

    val extras = Bundle()
    extras.putInt(ActionBroadcastReceiver.KEY_ACTION_ID, actionSourceId)
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_VIEW_ID, id)
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_MANAGER_ID, manager?.id)
    actionIntent.putExtras(extras)

    if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      return PendingIntent.getBroadcast(
              this, actionSourceId, actionIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
    } else {
      return PendingIntent.getBroadcast(
              this, actionSourceId, actionIntent, PendingIntent.FLAG_UPDATE_CURRENT)
    }
  }

  override fun dispose() {
    onStop()
    onDestroy()
    channelDelegate?.dispose()
    channelDelegate = null
    manager?.let { currentManager ->
      if (currentManager.browsers.containsKey(id)) {
        currentManager.browsers[id] = null
      }
    }
    manager = null
  }

  fun close() {
    onStop()
    onDestroy()
    customTabsSession = null
    finish()
    channelDelegate?.onClosed()
  }
}
