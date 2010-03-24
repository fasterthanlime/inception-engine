import engine/[Engine, Entity, Property, Update, Message]

main: func {
    
    engine := Engine new()

    engine addEntity(App new())
    engine addEntity(QuitManager new())
    
    engine run()
    
}

App: class extends Entity {
    
    init: func ~app {
        //super("app")
        name = "app"
        
        listen(QuitMessage, func (m: QuitMessage) {
            "%s received message from %s, must quit!" format(m target name, m sender name) println()
            exit(0)
        })        
    }
    
}

QuitManager: class extends Entity {
    
    count := 5
    
    init: func ~qm {
        //super("quit_manager")
        name = "quit_manager"
    }
    
    update: func {
        super()
        
        if(count > 0) {
            count -= 1; "%d iters left" format(count) println()
        } else {
            send(engine getEntity("app"), QuitMessage new())
        }
    }
    
}

QuitMessage: class extends Message {}

