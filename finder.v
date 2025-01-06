module cdv

@[params]
struct Paths {
	macos_paths []string
	win_paths   []string
	linux_paths []string
	other_paths []string
}

fn (p Paths) get_paths() []string {
	$if macos {
		return p.macos_paths
	} $else $if linux {
		return p.linux_paths
	} $else $if windows {
		return p.win_paths
	}
	if p.other_paths.len == 0 {
		return p.linux_paths
	}
	return p.other_paths
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
		macos_paths: [
			'Google Chrome',
			'Chromium',
		]
		win_paths:   ['chrome.exe', 'chromium.exe']
		linux_paths: [
			'google-chrome',
			'google-chrome-stable',
			'chromium-browser',
			'chromium',
		]
	)
}

pub fn find_edge() !string {
	return find_path_os(
		macos_paths: ['Microsoft Edge']
		win_paths:   ['msedge.exe', 'MicrosoftEdge.exe']
		linux_paths: ['microsoft-edge', 'microsoft-edge-stable']
	)
}

pub fn find_firefox() !string {
	return find_path_os(
		macos_paths: ['firefox', 'Firefox']
		win_paths:   ['firefox.exe']
		linux_paths: ['firefox']
	)
}
