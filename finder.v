module cdv

pub fn find_chrome() !string {
	mut path, mut list := '', []string{}
	$if macos {
		list = [
			'Google Chrome',
			'Chromium',
		]
	} $else $if windows {
		list = ['chrome.exe', 'chromium.exe']
	} $else {
		list = [
			'google-chrome',
			'google-chrome-stable',
			'chromium-browser',
			'chromium',
		]
	}
	for p in list {
		path = find_executable(p)
		if path != '' {
			break
		}
	}
	if path == '' {
		return error('cannot find chrome path')
	}
	return path
}
