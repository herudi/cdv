module cdv

@[params]
struct Paths {
	macos   []string
	windows []string
	linux   []string
	other   []string
}

fn (f Paths) get_paths() []string {
	$if macos {
		return f.macos
	} $else $if linux {
		return f.linux
	} $else $if windows {
		return f.windows
	}
	if f.other.len == 0 {
		return f.linux
	}
	return f.other
}

pub fn find_path_os(data Paths) !string {
	mut path := ''
	paths := data.get_paths()
	for p in paths {
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

pub fn find_chrome() !string {
	return find_path_os(
		macos:   [
			'Google Chrome',
			'Chromium',
		]
		windows: ['chrome.exe', 'chromium.exe']
		linux:   [
			'google-chrome',
			'google-chrome-stable',
			'chromium-browser',
			'chromium',
		]
	)
}

pub fn find_edge() !string {
	return find_path_os(
		macos:   ['Microsoft Edge']
		windows: ['msedge.exe', 'MicrosoftEdge.exe']
		linux:   ['microsoft-edge', 'microsoft-edge-stable']
	)
}

pub fn find_firefox() !string {
	return find_path_os(
		macos:   ['firefox', 'Firefox']
		windows: ['firefox.exe']
		linux:   ['firefox']
	)
}
