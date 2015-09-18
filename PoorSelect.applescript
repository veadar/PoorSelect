on run --for dialog
	if existsWindow() then
		display dialog "Filter word" default answer "" buttons {"OK"} default button 1
		set userInput to text returned of result
		main(userInput)
	end if
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
	
	set shellText to "ls " & quoted form of posixPath & " | iconv -f UTF-8-MAC -t UTF-8 | grep " & userInput
	
	try
		set tempList to do shell script shellText
		
		script listWrapper
			property contents : paragraphs of tempList
		end script
		
		set fileList to {}
		
		repeat with an_item in contents of listWrapper
			set filePath to posixPath & an_item
			set end of fileList to POSIX file filePath as alias
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
