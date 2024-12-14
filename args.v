module cdv

pub const def_args = [
	'--disable-features=Translate,OptimizationHints,MediaRouter,DialMediaRouteProvider,CalculateNativeWinOcclusion,InterestFeedContentSuggestions,CertificateTransparencyComponentUpdater,AutofillServerCommunication,PrivacySandboxSettings4',
	// Disable all chrome extensions
	'--disable-extensions',
	// Disable some extensions that aren't affected by --disable-extensions
	'--disable-component-extensions-with-background-pages',
	// Disable various background network services, including extension updating,
	//   safe browsing service, upgrade detector, translate, UMA
	'--disable-background-networking',
	// Don't update the browser 'components' listed at chrome://components/
	'--disable-component-update',
	// Disables client-side phishing detection.
	'--disable-client-side-phishing-detection',
	// Disable syncing to a Google account
	'--disable-sync',
	// Disable reporting to UMA, but allows for collection
	'--metrics-recording-only',
	// Disable installation of default apps on first run
	'--disable-default-apps',
	// Mute any audio
	'--mute-audio',
	// Disable the default browser check, do not prompt to set it as such
	'--no-default-browser-check',
	// Skip first run wizards
	'--no-first-run',
	// Disable backgrounding renders for occluded windows
	'--disable-backgrounding-occluded-windows',
	// Disable renderer process backgrounding
	'--disable-renderer-backgrounding',
	// Disable task throttling of timer tasks from background pages.
	'--disable-background-timer-throttling',
	// Disable the default throttling of IPC between renderer & browser processes.
	'--disable-ipc-flooding-protection',
	// Avoid potential instability of using Gnome Keyring or KDE wallet. crbug.com/571003 crbug.com/991424
	'--password-store=basic',
	// Use mock keychain on Mac to prevent blocking permissions dialogs
	'--use-mock-keychain',
	// Disable background tracing (aka slow reports & deep reports) to avoid 'Tracing already started'
	'--force-fieldtrials=*BackgroundTracing/default/',
	// Suppresses hang monitor dialogs in renderer processes. This flag may allow slow unload handlers on a page to prevent the tab from closing.
	'--disable-hang-monitor',
	// Reloading a page that came from a POST normally prompts the user.
	'--disable-prompt-on-repost',
	// Disables Domain Reliability Monitoring, which tracks whether the browser has difficulty contacting Google-owned sites and uploads reports to Google.
	'--disable-domain-reliability',
	// Disable the in-product Help (IPH) system.
	'--propagate-iph-for-testing',
]
