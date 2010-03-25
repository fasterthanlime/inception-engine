use readline
import readline
import Entity
import threading/[Runnable, Thread]

ConsoleT: class extends Runnable {
	console: Console
	init: func ~ct (=console) {}
	run: func {
		while(true)
			console input()
	}
}

Console: class extends Entity {
	init: func ~cons(.name) {
		super("name")
		Thread new(ConsoleT new(this)) start()
	}
		
	input: func {
		line := Readline readLine(">> ")
		line println()
		if(line == "exit") engine exit()
		if(!line isEmpty()) Readline addHistory(line)
		free(line)
	}
}
