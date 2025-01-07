module cdv

import x.json2 as json

const key_map = {
	'0':                  {
		'keyCode': json.Any(48)
		'key':     '0'
		'code':    'Digit0'
	}
	'1':                  {
		'keyCode': json.Any(49)
		'key':     '1'
		'code':    'Digit1'
	}
	'2':                  {
		'keyCode': json.Any(50)
		'key':     '2'
		'code':    'Digit2'
	}
	'3':                  {
		'keyCode': json.Any(51)
		'key':     '3'
		'code':    'Digit3'
	}
	'4':                  {
		'keyCode': json.Any(52)
		'key':     '4'
		'code':    'Digit4'
	}
	'5':                  {
		'keyCode': json.Any(53)
		'key':     '5'
		'code':    'Digit5'
	}
	'6':                  {
		'keyCode': json.Any(54)
		'key':     '6'
		'code':    'Digit6'
	}
	'7':                  {
		'keyCode': json.Any(55)
		'key':     '7'
		'code':    'Digit7'
	}
	'8':                  {
		'keyCode': json.Any(56)
		'key':     '8'
		'code':    'Digit8'
	}
	'9':                  {
		'keyCode': json.Any(57)
		'key':     '9'
		'code':    'Digit9'
	}
	'Power':              {
		'key':  json.Any('Power')
		'code': 'Power'
	}
	'Eject':              {
		'key':  json.Any('Eject')
		'code': 'Eject'
	}
	'Abort':              {
		'keyCode': json.Any(3)
		'code':    'Abort'
		'key':     'Cancel'
	}
	'Help':               {
		'keyCode': json.Any(6)
		'code':    'Help'
		'key':     'Help'
	}
	'Backspace':          {
		'keyCode': json.Any(8)
		'code':    'Backspace'
		'key':     'Backspace'
	}
	'Tab':                {
		'keyCode': json.Any(9)
		'code':    'Tab'
		'key':     'Tab'
	}
	'Numpad5':            {
		'keyCode':      json.Any(12)
		'shiftKeyCode': 101
		'key':          'Clear'
		'code':         'Numpad5'
		'shiftKey':     '5'
		'location':     3
	}
	'NumpadEnter':        {
		'keyCode':  json.Any(13)
		'code':     'NumpadEnter'
		'key':      'Enter'
		'text':     '\r'
		'location': 3
	}
	'Enter':              {
		'keyCode': json.Any(13)
		'code':    'Enter'
		'key':     'Enter'
		'text':    '\r'
	}
	'\r':                 {
		'keyCode': json.Any(13)
		'code':    'Enter'
		'key':     'Enter'
		'text':    '\r'
	}
	'\n':                 {
		'keyCode': json.Any(13)
		'code':    'Enter'
		'key':     'Enter'
		'text':    '\r'
	}
	'ShiftLeft':          {
		'keyCode':  json.Any(16)
		'code':     'ShiftLeft'
		'key':      'Shift'
		'location': 1
	}
	'ShiftRight':         {
		'keyCode':  json.Any(16)
		'code':     'ShiftRight'
		'key':      'Shift'
		'location': 2
	}
	'ControlLeft':        {
		'keyCode':  json.Any(17)
		'code':     'ControlLeft'
		'key':      'Control'
		'location': 1
	}
	'ControlRight':       {
		'keyCode':  json.Any(17)
		'code':     'ControlRight'
		'key':      'Control'
		'location': 2
	}
	'AltLeft':            {
		'keyCode':  json.Any(18)
		'code':     'AltLeft'
		'key':      'Alt'
		'location': 1
	}
	'AltRight':           {
		'keyCode':  json.Any(18)
		'code':     'AltRight'
		'key':      'Alt'
		'location': 2
	}
	'Pause':              {
		'keyCode': json.Any(19)
		'code':    'Pause'
		'key':     'Pause'
	}
	'CapsLock':           {
		'keyCode': json.Any(20)
		'code':    'CapsLock'
		'key':     'CapsLock'
	}
	'Escape':             {
		'keyCode': json.Any(27)
		'code':    'Escape'
		'key':     'Escape'
	}
	'Convert':            {
		'keyCode': json.Any(28)
		'code':    'Convert'
		'key':     'Convert'
	}
	'NonConvert':         {
		'keyCode': json.Any(29)
		'code':    'NonConvert'
		'key':     'NonConvert'
	}
	'Space':              {
		'keyCode': json.Any(32)
		'code':    'Space'
		'key':     ' '
	}
	'Numpad9':            {
		'keyCode':      json.Any(33)
		'shiftKeyCode': 105
		'key':          'PageUp'
		'code':         'Numpad9'
		'shiftKey':     '9'
		'location':     3
	}
	'PageUp':             {
		'keyCode': json.Any(33)
		'code':    'PageUp'
		'key':     'PageUp'
	}
	'Numpad3':            {
		'keyCode':      json.Any(34)
		'shiftKeyCode': 99
		'key':          'PageDown'
		'code':         'Numpad3'
		'shiftKey':     '3'
		'location':     3
	}
	'PageDown':           {
		'keyCode': json.Any(34)
		'code':    'PageDown'
		'key':     'PageDown'
	}
	'End':                {
		'keyCode': json.Any(35)
		'code':    'End'
		'key':     'End'
	}
	'Numpad1':            {
		'keyCode':      json.Any(35)
		'shiftKeyCode': 97
		'key':          'End'
		'code':         'Numpad1'
		'shiftKey':     '1'
		'location':     3
	}
	'Home':               {
		'keyCode': json.Any(36)
		'code':    'Home'
		'key':     'Home'
	}
	'Numpad7':            {
		'keyCode':      json.Any(36)
		'shiftKeyCode': 103
		'key':          'Home'
		'code':         'Numpad7'
		'shiftKey':     '7'
		'location':     3
	}
	'ArrowLeft':          {
		'keyCode': json.Any(37)
		'code':    'ArrowLeft'
		'key':     'ArrowLeft'
	}
	'Numpad4':            {
		'keyCode':      json.Any(37)
		'shiftKeyCode': 100
		'key':          'ArrowLeft'
		'code':         'Numpad4'
		'shiftKey':     '4'
		'location':     3
	}
	'Numpad8':            {
		'keyCode':      json.Any(38)
		'shiftKeyCode': 104
		'key':          'ArrowUp'
		'code':         'Numpad8'
		'shiftKey':     '8'
		'location':     3
	}
	'ArrowUp':            {
		'keyCode': json.Any(38)
		'code':    'ArrowUp'
		'key':     'ArrowUp'
	}
	'ArrowRight':         {
		'keyCode': json.Any(39)
		'code':    'ArrowRight'
		'key':     'ArrowRight'
	}
	'Numpad6':            {
		'keyCode':      json.Any(39)
		'shiftKeyCode': 102
		'key':          'ArrowRight'
		'code':         'Numpad6'
		'shiftKey':     '6'
		'location':     3
	}
	'Numpad2':            {
		'keyCode':      json.Any(40)
		'shiftKeyCode': 98
		'key':          'ArrowDown'
		'code':         'Numpad2'
		'shiftKey':     '2'
		'location':     3
	}
	'ArrowDown':          {
		'keyCode': json.Any(40)
		'code':    'ArrowDown'
		'key':     'ArrowDown'
	}
	'Select':             {
		'keyCode': json.Any(41)
		'code':    'Select'
		'key':     'Select'
	}
	'Open':               {
		'keyCode': json.Any(43)
		'code':    'Open'
		'key':     'Execute'
	}
	'PrintScreen':        {
		'keyCode': json.Any(44)
		'code':    'PrintScreen'
		'key':     'PrintScreen'
	}
	'Insert':             {
		'keyCode': json.Any(45)
		'code':    'Insert'
		'key':     'Insert'
	}
	'Numpad0':            {
		'keyCode':      json.Any(45)
		'shiftKeyCode': 96
		'key':          'Insert'
		'code':         'Numpad0'
		'shiftKey':     '0'
		'location':     3
	}
	'Delete':             {
		'keyCode': json.Any(46)
		'code':    'Delete'
		'key':     'Delete'
	}
	'NumpadDecimal':      {
		'keyCode':      json.Any(46)
		'shiftKeyCode': 110
		'code':         'NumpadDecimal'
		'key':          '\u0000'
		'shiftKey':     '.'
		'location':     3
	}
	'Digit0':             {
		'keyCode':  json.Any(48)
		'code':     'Digit0'
		'shiftKey': ')'
		'key':      '0'
	}
	'Digit1':             {
		'keyCode':  json.Any(49)
		'code':     'Digit1'
		'shiftKey': '!'
		'key':      '1'
	}
	'Digit2':             {
		'keyCode':  json.Any(50)
		'code':     'Digit2'
		'shiftKey': '@'
		'key':      '2'
	}
	'Digit3':             {
		'keyCode':  json.Any(51)
		'code':     'Digit3'
		'shiftKey': '#'
		'key':      '3'
	}
	'Digit4':             {
		'keyCode':  json.Any(52)
		'code':     'Digit4'
		'shiftKey': '$'
		'key':      '4'
	}
	'Digit5':             {
		'keyCode':  json.Any(53)
		'code':     'Digit5'
		'shiftKey': '%'
		'key':      '5'
	}
	'Digit6':             {
		'keyCode':  json.Any(54)
		'code':     'Digit6'
		'shiftKey': '^'
		'key':      '6'
	}
	'Digit7':             {
		'keyCode':  json.Any(55)
		'code':     'Digit7'
		'shiftKey': '&'
		'key':      '7'
	}
	'Digit8':             {
		'keyCode':  json.Any(56)
		'code':     'Digit8'
		'shiftKey': '*'
		'key':      '8'
	}
	'Digit9':             {
		'keyCode':  json.Any(57)
		'code':     'Digit9'
		'shiftKey': '('
		'key':      '9'
	}
	'KeyA':               {
		'keyCode':  json.Any(65)
		'code':     'KeyA'
		'shiftKey': 'A'
		'key':      'a'
	}
	'KeyB':               {
		'keyCode':  json.Any(66)
		'code':     'KeyB'
		'shiftKey': 'B'
		'key':      'b'
	}
	'KeyC':               {
		'keyCode':  json.Any(67)
		'code':     'KeyC'
		'shiftKey': 'C'
		'key':      'c'
	}
	'KeyD':               {
		'keyCode':  json.Any(68)
		'code':     'KeyD'
		'shiftKey': 'D'
		'key':      'd'
	}
	'KeyE':               {
		'keyCode':  json.Any(69)
		'code':     'KeyE'
		'shiftKey': 'E'
		'key':      'e'
	}
	'KeyF':               {
		'keyCode':  json.Any(70)
		'code':     'KeyF'
		'shiftKey': 'F'
		'key':      'f'
	}
	'KeyG':               {
		'keyCode':  json.Any(71)
		'code':     'KeyG'
		'shiftKey': 'G'
		'key':      'g'
	}
	'KeyH':               {
		'keyCode':  json.Any(72)
		'code':     'KeyH'
		'shiftKey': 'H'
		'key':      'h'
	}
	'KeyI':               {
		'keyCode':  json.Any(73)
		'code':     'KeyI'
		'shiftKey': 'I'
		'key':      'i'
	}
	'KeyJ':               {
		'keyCode':  json.Any(74)
		'code':     'KeyJ'
		'shiftKey': 'J'
		'key':      'j'
	}
	'KeyK':               {
		'keyCode':  json.Any(75)
		'code':     'KeyK'
		'shiftKey': 'K'
		'key':      'k'
	}
	'KeyL':               {
		'keyCode':  json.Any(76)
		'code':     'KeyL'
		'shiftKey': 'L'
		'key':      'l'
	}
	'KeyM':               {
		'keyCode':  json.Any(77)
		'code':     'KeyM'
		'shiftKey': 'M'
		'key':      'm'
	}
	'KeyN':               {
		'keyCode':  json.Any(78)
		'code':     'KeyN'
		'shiftKey': 'N'
		'key':      'n'
	}
	'KeyO':               {
		'keyCode':  json.Any(79)
		'code':     'KeyO'
		'shiftKey': 'O'
		'key':      'o'
	}
	'KeyP':               {
		'keyCode':  json.Any(80)
		'code':     'KeyP'
		'shiftKey': 'P'
		'key':      'p'
	}
	'KeyQ':               {
		'keyCode':  json.Any(81)
		'code':     'KeyQ'
		'shiftKey': 'Q'
		'key':      'q'
	}
	'KeyR':               {
		'keyCode':  json.Any(82)
		'code':     'KeyR'
		'shiftKey': 'R'
		'key':      'r'
	}
	'KeyS':               {
		'keyCode':  json.Any(83)
		'code':     'KeyS'
		'shiftKey': 'S'
		'key':      's'
	}
	'KeyT':               {
		'keyCode':  json.Any(84)
		'code':     'KeyT'
		'shiftKey': 'T'
		'key':      't'
	}
	'KeyU':               {
		'keyCode':  json.Any(85)
		'code':     'KeyU'
		'shiftKey': 'U'
		'key':      'u'
	}
	'KeyV':               {
		'keyCode':  json.Any(86)
		'code':     'KeyV'
		'shiftKey': 'V'
		'key':      'v'
	}
	'KeyW':               {
		'keyCode':  json.Any(87)
		'code':     'KeyW'
		'shiftKey': 'W'
		'key':      'w'
	}
	'KeyX':               {
		'keyCode':  json.Any(88)
		'code':     'KeyX'
		'shiftKey': 'X'
		'key':      'x'
	}
	'KeyY':               {
		'keyCode':  json.Any(89)
		'code':     'KeyY'
		'shiftKey': 'Y'
		'key':      'y'
	}
	'KeyZ':               {
		'keyCode':  json.Any(90)
		'code':     'KeyZ'
		'shiftKey': 'Z'
		'key':      'z'
	}
	'MetaLeft':           {
		'keyCode':  json.Any(91)
		'code':     'MetaLeft'
		'key':      'Meta'
		'location': 1
	}
	'MetaRight':          {
		'keyCode':  json.Any(92)
		'code':     'MetaRight'
		'key':      'Meta'
		'location': 2
	}
	'ContextMenu':        {
		'keyCode': json.Any(93)
		'code':    'ContextMenu'
		'key':     'ContextMenu'
	}
	'NumpadMultiply':     {
		'keyCode':  json.Any(106)
		'code':     'NumpadMultiply'
		'key':      '*'
		'location': 3
	}
	'NumpadAdd':          {
		'keyCode':  json.Any(107)
		'code':     'NumpadAdd'
		'key':      '+'
		'location': 3
	}
	'NumpadSubtract':     {
		'keyCode':  json.Any(109)
		'code':     'NumpadSubtract'
		'key':      '-'
		'location': 3
	}
	'NumpadDivide':       {
		'keyCode':  json.Any(111)
		'code':     'NumpadDivide'
		'key':      '/'
		'location': 3
	}
	'F1':                 {
		'keyCode': json.Any(112)
		'code':    'F1'
		'key':     'F1'
	}
	'F2':                 {
		'keyCode': json.Any(113)
		'code':    'F2'
		'key':     'F2'
	}
	'F3':                 {
		'keyCode': json.Any(114)
		'code':    'F3'
		'key':     'F3'
	}
	'F4':                 {
		'keyCode': json.Any(115)
		'code':    'F4'
		'key':     'F4'
	}
	'F5':                 {
		'keyCode': json.Any(116)
		'code':    'F5'
		'key':     'F5'
	}
	'F6':                 {
		'keyCode': json.Any(117)
		'code':    'F6'
		'key':     'F6'
	}
	'F7':                 {
		'keyCode': json.Any(118)
		'code':    'F7'
		'key':     'F7'
	}
	'F8':                 {
		'keyCode': json.Any(119)
		'code':    'F8'
		'key':     'F8'
	}
	'F9':                 {
		'keyCode': json.Any(120)
		'code':    'F9'
		'key':     'F9'
	}
	'F10':                {
		'keyCode': json.Any(121)
		'code':    'F10'
		'key':     'F10'
	}
	'F11':                {
		'keyCode': json.Any(122)
		'code':    'F11'
		'key':     'F11'
	}
	'F12':                {
		'keyCode': json.Any(123)
		'code':    'F12'
		'key':     'F12'
	}
	'F13':                {
		'keyCode': json.Any(124)
		'code':    'F13'
		'key':     'F13'
	}
	'F14':                {
		'keyCode': json.Any(125)
		'code':    'F14'
		'key':     'F14'
	}
	'F15':                {
		'keyCode': json.Any(126)
		'code':    'F15'
		'key':     'F15'
	}
	'F16':                {
		'keyCode': json.Any(127)
		'code':    'F16'
		'key':     'F16'
	}
	'F17':                {
		'keyCode': json.Any(128)
		'code':    'F17'
		'key':     'F17'
	}
	'F18':                {
		'keyCode': json.Any(129)
		'code':    'F18'
		'key':     'F18'
	}
	'F19':                {
		'keyCode': json.Any(130)
		'code':    'F19'
		'key':     'F19'
	}
	'F20':                {
		'keyCode': json.Any(131)
		'code':    'F20'
		'key':     'F20'
	}
	'F21':                {
		'keyCode': json.Any(132)
		'code':    'F21'
		'key':     'F21'
	}
	'F22':                {
		'keyCode': json.Any(133)
		'code':    'F22'
		'key':     'F22'
	}
	'F23':                {
		'keyCode': json.Any(134)
		'code':    'F23'
		'key':     'F23'
	}
	'F24':                {
		'keyCode': json.Any(135)
		'code':    'F24'
		'key':     'F24'
	}
	'NumLock':            {
		'keyCode': json.Any(144)
		'code':    'NumLock'
		'key':     'NumLock'
	}
	'ScrollLock':         {
		'keyCode': json.Any(145)
		'code':    'ScrollLock'
		'key':     'ScrollLock'
	}
	'AudioVolumeMute':    {
		'keyCode': json.Any(173)
		'code':    'AudioVolumeMute'
		'key':     'AudioVolumeMute'
	}
	'AudioVolumeDown':    {
		'keyCode': json.Any(174)
		'code':    'AudioVolumeDown'
		'key':     'AudioVolumeDown'
	}
	'AudioVolumeUp':      {
		'keyCode': json.Any(175)
		'code':    'AudioVolumeUp'
		'key':     'AudioVolumeUp'
	}
	'MediaTrackNext':     {
		'keyCode': json.Any(176)
		'code':    'MediaTrackNext'
		'key':     'MediaTrackNext'
	}
	'MediaTrackPrevious': {
		'keyCode': json.Any(177)
		'code':    'MediaTrackPrevious'
		'key':     'MediaTrackPrevious'
	}
	'MediaStop':          {
		'keyCode': json.Any(178)
		'code':    'MediaStop'
		'key':     'MediaStop'
	}
	'MediaPlayPause':     {
		'keyCode': json.Any(179)
		'code':    'MediaPlayPause'
		'key':     'MediaPlayPause'
	}
	'Semicolon':          {
		'keyCode':  json.Any(186)
		'code':     'Semicolon'
		'shiftKey': ':'
		'key':      ';'
	}
	'Equal':              {
		'keyCode':  json.Any(187)
		'code':     'Equal'
		'shiftKey': '+'
		'key':      '='
	}
	'NumpadEqual':        {
		'keyCode':  json.Any(187)
		'code':     'NumpadEqual'
		'key':      '='
		'location': 3
	}
	'Comma':              {
		'keyCode':  json.Any(188)
		'code':     'Comma'
		'shiftKey': '<'
		'key':      ','
	}
	'Minus':              {
		'keyCode':  json.Any(189)
		'code':     'Minus'
		'shiftKey': '_'
		'key':      '-'
	}
	'Period':             {
		'keyCode':  json.Any(190)
		'code':     'Period'
		'shiftKey': '>'
		'key':      '.'
	}
	'Slash':              {
		'keyCode':  json.Any(191)
		'code':     'Slash'
		'shiftKey': '?'
		'key':      '/'
	}
	'Backquote':          {
		'keyCode':  json.Any(192)
		'code':     'Backquote'
		'shiftKey': '~'
		'key':      '`'
	}
	'BracketLeft':        {
		'keyCode':  json.Any(219)
		'code':     'BracketLeft'
		'shiftKey': '{'
		'key':      '['
	}
	'Backslash':          {
		'keyCode':  json.Any(220)
		'code':     'Backslash'
		'shiftKey': '|'
		'key':      '\\'
	}
	'BracketRight':       {
		'keyCode':  json.Any(221)
		'code':     'BracketRight'
		'shiftKey': '}'
		'key':      ']'
	}
	'Quote':              {
		'keyCode':  json.Any(222)
		'code':     'Quote'
		'shiftKey': '"'
		'key':      "'"
	}
	'AltGraph':           {
		'keyCode': json.Any(225)
		'code':    'AltGraph'
		'key':     'AltGraph'
	}
	'Props':              {
		'keyCode': json.Any(247)
		'code':    'Props'
		'key':     'CrSel'
	}
	'Cancel':             {
		'keyCode': json.Any(3)
		'key':     'Cancel'
		'code':    'Abort'
	}
	'Clear':              {
		'keyCode':  json.Any(12)
		'key':      'Clear'
		'code':     'Numpad5'
		'location': 3
	}
	'Shift':              {
		'keyCode':  json.Any(16)
		'key':      'Shift'
		'code':     'ShiftLeft'
		'location': 1
	}
	'Control':            {
		'keyCode':  json.Any(17)
		'key':      'Control'
		'code':     'ControlLeft'
		'location': 1
	}
	'Alt':                {
		'keyCode':  json.Any(18)
		'key':      'Alt'
		'code':     'AltLeft'
		'location': 1
	}
	'Accept':             {
		'keyCode': json.Any(30)
		'key':     'Accept'
	}
	'ModeChange':         {
		'keyCode': json.Any(31)
		'key':     'ModeChange'
	}
	' ':                  {
		'keyCode': json.Any(32)
		'key':     ' '
		'code':    'Space'
	}
	'Print':              {
		'keyCode': json.Any(42)
		'key':     'Print'
	}
	'Execute':            {
		'keyCode': json.Any(43)
		'key':     'Execute'
		'code':    'Open'
	}
	'\u0000':             {
		'keyCode':  json.Any(46)
		'key':      '\u0000'
		'code':     'NumpadDecimal'
		'location': 3
	}
	'a':                  {
		'keyCode': json.Any(65)
		'key':     'a'
		'code':    'KeyA'
	}
	'b':                  {
		'keyCode': json.Any(66)
		'key':     'b'
		'code':    'KeyB'
	}
	'c':                  {
		'keyCode': json.Any(67)
		'key':     'c'
		'code':    'KeyC'
	}
	'd':                  {
		'keyCode': json.Any(68)
		'key':     'd'
		'code':    'KeyD'
	}
	'e':                  {
		'keyCode': json.Any(69)
		'key':     'e'
		'code':    'KeyE'
	}
	'f':                  {
		'keyCode': json.Any(70)
		'key':     'f'
		'code':    'KeyF'
	}
	'g':                  {
		'keyCode': json.Any(71)
		'key':     'g'
		'code':    'KeyG'
	}
	'h':                  {
		'keyCode': json.Any(72)
		'key':     'h'
		'code':    'KeyH'
	}
	'i':                  {
		'keyCode': json.Any(73)
		'key':     'i'
		'code':    'KeyI'
	}
	'j':                  {
		'keyCode': json.Any(74)
		'key':     'j'
		'code':    'KeyJ'
	}
	'k':                  {
		'keyCode': json.Any(75)
		'key':     'k'
		'code':    'KeyK'
	}
	'l':                  {
		'keyCode': json.Any(76)
		'key':     'l'
		'code':    'KeyL'
	}
	'm':                  {
		'keyCode': json.Any(77)
		'key':     'm'
		'code':    'KeyM'
	}
	'n':                  {
		'keyCode': json.Any(78)
		'key':     'n'
		'code':    'KeyN'
	}
	'o':                  {
		'keyCode': json.Any(79)
		'key':     'o'
		'code':    'KeyO'
	}
	'p':                  {
		'keyCode': json.Any(80)
		'key':     'p'
		'code':    'KeyP'
	}
	'q':                  {
		'keyCode': json.Any(81)
		'key':     'q'
		'code':    'KeyQ'
	}
	'r':                  {
		'keyCode': json.Any(82)
		'key':     'r'
		'code':    'KeyR'
	}
	's':                  {
		'keyCode': json.Any(83)
		'key':     's'
		'code':    'KeyS'
	}
	't':                  {
		'keyCode': json.Any(84)
		'key':     't'
		'code':    'KeyT'
	}
	'u':                  {
		'keyCode': json.Any(85)
		'key':     'u'
		'code':    'KeyU'
	}
	'v':                  {
		'keyCode': json.Any(86)
		'key':     'v'
		'code':    'KeyV'
	}
	'w':                  {
		'keyCode': json.Any(87)
		'key':     'w'
		'code':    'KeyW'
	}
	'x':                  {
		'keyCode': json.Any(88)
		'key':     'x'
		'code':    'KeyX'
	}
	'y':                  {
		'keyCode': json.Any(89)
		'key':     'y'
		'code':    'KeyY'
	}
	'z':                  {
		'keyCode': json.Any(90)
		'key':     'z'
		'code':    'KeyZ'
	}
	'Meta':               {
		'keyCode':  json.Any(91)
		'key':      'Meta'
		'code':     'MetaLeft'
		'location': 1
	}
	'*':                  {
		'keyCode':  json.Any(106)
		'key':      '*'
		'code':     'NumpadMultiply'
		'location': 3
	}
	'+':                  {
		'keyCode':  json.Any(107)
		'key':      '+'
		'code':     'NumpadAdd'
		'location': 3
	}
	'-':                  {
		'keyCode':  json.Any(109)
		'key':      '-'
		'code':     'NumpadSubtract'
		'location': 3
	}
	'/':                  {
		'keyCode':  json.Any(111)
		'key':      '/'
		'code':     'NumpadDivide'
		'location': 3
	}
	';':                  {
		'keyCode': json.Any(186)
		'key':     ';'
		'code':    'Semicolon'
	}
	'=':                  {
		'keyCode': json.Any(187)
		'key':     '='
		'code':    'Equal'
	}
	',':                  {
		'keyCode': json.Any(188)
		'key':     ','
		'code':    'Comma'
	}
	'.':                  {
		'keyCode': json.Any(190)
		'key':     '.'
		'code':    'Period'
	}
	'`':                  {
		'keyCode': json.Any(192)
		'key':     '`'
		'code':    'Backquote'
	}
	'[':                  {
		'keyCode': json.Any(219)
		'key':     '['
		'code':    'BracketLeft'
	}
	'\\':                 {
		'keyCode': json.Any(220)
		'key':     '\\'
		'code':    'Backslash'
	}
	']':                  {
		'keyCode': json.Any(221)
		'key':     ']'
		'code':    'BracketRight'
	}
	"'":                  {
		'keyCode': json.Any(222)
		'key':     "'"
		'code':    'Quote'
	}
	'Attn':               {
		'keyCode': json.Any(246)
		'key':     'Attn'
	}
	'CrSel':              {
		'keyCode': json.Any(247)
		'key':     'CrSel'
		'code':    'Props'
	}
	'ExSel':              {
		'keyCode': json.Any(248)
		'key':     'ExSel'
	}
	'EraseEof':           {
		'keyCode': json.Any(249)
		'key':     'EraseEof'
	}
	'Play':               {
		'keyCode': json.Any(250)
		'key':     'Play'
	}
	'ZoomOut':            {
		'keyCode': json.Any(251)
		'key':     'ZoomOut'
	}
	')':                  {
		'keyCode': json.Any(48)
		'key':     ')'
		'code':    'Digit0'
	}
	'!':                  {
		'keyCode': json.Any(49)
		'key':     '!'
		'code':    'Digit1'
	}
	'@':                  {
		'keyCode': json.Any(50)
		'key':     '@'
		'code':    'Digit2'
	}
	'#':                  {
		'keyCode': json.Any(51)
		'key':     '#'
		'code':    'Digit3'
	}
	'$':                  {
		'keyCode': json.Any(52)
		'key':     '$'
		'code':    'Digit4'
	}
	'%':                  {
		'keyCode': json.Any(53)
		'key':     '%'
		'code':    'Digit5'
	}
	'^':                  {
		'keyCode': json.Any(54)
		'key':     '^'
		'code':    'Digit6'
	}
	'&':                  {
		'keyCode': json.Any(55)
		'key':     '&'
		'code':    'Digit7'
	}
	'(':                  {
		'keyCode': json.Any(57)
		'key':     '('
		'code':    'Digit9'
	}
	'A':                  {
		'keyCode': json.Any(65)
		'key':     'A'
		'code':    'KeyA'
	}
	'B':                  {
		'keyCode': json.Any(66)
		'key':     'B'
		'code':    'KeyB'
	}
	'C':                  {
		'keyCode': json.Any(67)
		'key':     'C'
		'code':    'KeyC'
	}
	'D':                  {
		'keyCode': json.Any(68)
		'key':     'D'
		'code':    'KeyD'
	}
	'E':                  {
		'keyCode': json.Any(69)
		'key':     'E'
		'code':    'KeyE'
	}
	'F':                  {
		'keyCode': json.Any(70)
		'key':     'F'
		'code':    'KeyF'
	}
	'G':                  {
		'keyCode': json.Any(71)
		'key':     'G'
		'code':    'KeyG'
	}
	'H':                  {
		'keyCode': json.Any(72)
		'key':     'H'
		'code':    'KeyH'
	}
	'I':                  {
		'keyCode': json.Any(73)
		'key':     'I'
		'code':    'KeyI'
	}
	'J':                  {
		'keyCode': json.Any(74)
		'key':     'J'
		'code':    'KeyJ'
	}
	'K':                  {
		'keyCode': json.Any(75)
		'key':     'K'
		'code':    'KeyK'
	}
	'L':                  {
		'keyCode': json.Any(76)
		'key':     'L'
		'code':    'KeyL'
	}
	'M':                  {
		'keyCode': json.Any(77)
		'key':     'M'
		'code':    'KeyM'
	}
	'N':                  {
		'keyCode': json.Any(78)
		'key':     'N'
		'code':    'KeyN'
	}
	'O':                  {
		'keyCode': json.Any(79)
		'key':     'O'
		'code':    'KeyO'
	}
	'P':                  {
		'keyCode': json.Any(80)
		'key':     'P'
		'code':    'KeyP'
	}
	'Q':                  {
		'keyCode': json.Any(81)
		'key':     'Q'
		'code':    'KeyQ'
	}
	'R':                  {
		'keyCode': json.Any(82)
		'key':     'R'
		'code':    'KeyR'
	}
	'S':                  {
		'keyCode': json.Any(83)
		'key':     'S'
		'code':    'KeyS'
	}
	'T':                  {
		'keyCode': json.Any(84)
		'key':     'T'
		'code':    'KeyT'
	}
	'U':                  {
		'keyCode': json.Any(85)
		'key':     'U'
		'code':    'KeyU'
	}
	'V':                  {
		'keyCode': json.Any(86)
		'key':     'V'
		'code':    'KeyV'
	}
	'W':                  {
		'keyCode': json.Any(87)
		'key':     'W'
		'code':    'KeyW'
	}
	'X':                  {
		'keyCode': json.Any(88)
		'key':     'X'
		'code':    'KeyX'
	}
	'Y':                  {
		'keyCode': json.Any(89)
		'key':     'Y'
		'code':    'KeyY'
	}
	'Z':                  {
		'keyCode': json.Any(90)
		'key':     'Z'
		'code':    'KeyZ'
	}
	':':                  {
		'keyCode': json.Any(186)
		'key':     ':'
		'code':    'Semicolon'
	}
	'<':                  {
		'keyCode': json.Any(188)
		'key':     '<'
		'code':    'Comma'
	}
	'_':                  {
		'keyCode': json.Any(189)
		'key':     '_'
		'code':    'Minus'
	}
	'>':                  {
		'keyCode': json.Any(190)
		'key':     '>'
		'code':    'Period'
	}
	'?':                  {
		'keyCode': json.Any(191)
		'key':     '?'
		'code':    'Slash'
	}
	'~':                  {
		'keyCode': json.Any(192)
		'key':     '~'
		'code':    'Backquote'
	}
	'{':                  {
		'keyCode': json.Any(219)
		'key':     '{'
		'code':    'BracketLeft'
	}
	'|':                  {
		'keyCode': json.Any(220)
		'key':     '|'
		'code':    'Backslash'
	}
	'}':                  {
		'keyCode': json.Any(221)
		'key':     '}'
		'code':    'BracketRight'
	}
	'"':                  {
		'keyCode': json.Any(222)
		'key':     '"'
		'code':    'Quote'
	}
	'SoftLeft':           {
		'key':      json.Any('SoftLeft')
		'code':     'SoftLeft'
		'location': 4
	}
	'SoftRight':          {
		'key':      json.Any('SoftRight')
		'code':     'SoftRight'
		'location': 4
	}
	'Camera':             {
		'keyCode':  json.Any(44)
		'key':      'Camera'
		'code':     'Camera'
		'location': 4
	}
	'Call':               {
		'key':      json.Any('Call')
		'code':     'Call'
		'location': 4
	}
	'EndCall':            {
		'keyCode':  json.Any(95)
		'key':      'EndCall'
		'code':     'EndCall'
		'location': 4
	}
	'VolumeDown':         {
		'keyCode':  json.Any(182)
		'key':      'VolumeDown'
		'code':     'VolumeDown'
		'location': 4
	}
	'VolumeUp':           {
		'keyCode':  json.Any(183)
		'key':      'VolumeUp'
		'code':     'VolumeUp'
		'location': 4
	}
}
