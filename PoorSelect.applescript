script MyScript
	if existsWindow() then
		display dialog "Filter word" default answer "" buttons {"and search", "or search", "search"} default button 3
		
		set userInput to result
		
		set userInputButton to button returned of userInput
		
		set userInputText to text returned of userInput
		
		if userInputButton is "search" then
			set userInput to userInputText
		else if userInputButton is "or search" then
			set textList to makeList(userInputText, " ")
			set userInput to ""
			repeat with i from 1 to number of items in textList
				set this_item to item i of textList
				set userInput to userInput & "-e " & this_item & " "
			end repeat
		else if userInputButton is "and search" then
			set userInput to replaceText(userInputText, " ", " | grep -i ")
		end if
		main(userInput)
	end if
end script

on run --for dialog
	local tempScript
	copy MyScript to tempScript
	run tempScript
end run

on alfred_script(userInput) --for Alfred
	if existsWindow() then
		main(userInput)
	end if
end alfred_script

on handle_string(userInput) --for LaunchBar
	if existsWindow() then
		main(userInput)
	end if
end handle_string

on existsWindow()
	tell application "Finder"
		if Finder window 1 exists then
			true
		else
			false
		end if
	end tell
end existsWindow

on main(userInput)
	tell application "Finder"
		set targetFolder to target of Finder window 1
		set posixPath to (targetFolder as alias)'s POSIX path
	end tell
	
	set shellText to "ls " & quoted form of posixPath & " | iconv -c -f UTF-8-MAC -t UTF-8 | grep -i " & userInput
	
	try
		set tempList to do shell script shellText
		
		script listWrapper
			property contents : paragraphs of tempList
		end script
		
		set fileList to {}
		
		repeat with an_item in contents of listWrapper
			try
				set filePath to posixPath & an_item
				set end of fileList to POSIX file filePath as alias
			end try
		end repeat
		
		tell application "Finder"
			reveal fileList
			activate
		end tell
		
		try
			display notification ((number of fileList) as text) & " items are matched"
		end try
	on error msg
		log msg
		try
			display notification "N/A"
		on error
			display alert "N/A"
		end try
		
	end try
end main

on makeList(theText, theDelimiter) --テキストを指定語句で区切り配列に格納する
	set tmp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theDelimiter
	set theList to every text item of theText
	set AppleScript's text item delimiters to tmp
	return theList
end makeList

on replaceText(theText, serchStr, replaceStr)
	set tmp to AppleScript's text item delimiters
	set AppleScript's text item delimiters to serchStr
	set theList to every text item of theText
	set AppleScript's text item delimiters to replaceStr
	set theText to theList as string
	set AppleScript's text item delimiters to tmp
	return theText
end replaceText