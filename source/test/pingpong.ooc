import engine/[Engine, Entity, Property, Update, Message]

main: func {
    
    engine := Engine new()

    bob   := Entity new("bob")
    alice := Entity new("alice")
    
    bob   addUpdate(PingPong new(alice))
    alice addUpdate(PingPong new(bob))
    
    engine addEntity(bob)
    engine addEntity(alice)
    
    engine run()
    
}

PingPong: class extends Update {
    
    sent := false
    sender, target: Entity
    
    init: func ~withEnt(=sender, =target) {
        target receive(PingMessage, func (m: PingMessage) {
            m target send(m sender, PongMessage new())
        })
        
        target receive(PongMessage, func (m: PongMessage) {
            printf("Received pong! I'm so dead!")
            m target set("alive", false)
        })
    }
    
    run: func (origin: Entity) -> Bool {
        if(!sent) {
            origin send(target, PingMessage new())
            sent = true
        }
        sender get("alive", Bool)
    }
    
}

PingMessage: class extends Message {}
PongMessage: class extends Message {}

