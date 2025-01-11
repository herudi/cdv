module cdv

const map_method = {
	'request':  'Network.requestWillBeSent'
	'response': 'Network.responseReceived'
	'console':  'Runtime.consoleAPICalled'
}

const cdv_msg_next = false
const cdv_msg_done = true
