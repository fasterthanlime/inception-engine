import engine/[Engine, Entity, Property, Update, Message]

main: func {
    
    engine := Engine new()

    bob   := Entity new("bob")
    alice := Entity new("alice")
    
    bob   addUpdate(PingPong new(bob, alice))
    alice addUpdate(PingPong new(alice, bob))
    
    engine addEntity(bob)
    engine addEntity(alice)
    
    engine run()
    
}

PingPong: class extends Update {
    
    sent := false
    sender, target: Entity
    
    init: func ~withEnt(=sender, =target) {
        sender set("alive", true)
        
        target receive(PingMessage, func (m: PingMessage) {
            "Here %s, received ping from %s, sending pong back" format(m sender name, m target name) println()
            m target send(m sender, PongMessage new())
        })
        
        target receive(PongMessage, func (m: PongMessage) {
            "Here %s, received pong from %s! I'm so dead!" format(m sender name, m target name) println()
            m target set("alive", false)
        })
    }
    
    run: func (origin: Entity) -> Bool {
        if(!sent) {
            "Here %s, sending ping to %s!" format(sender name, target name) println()
            origin send(target, PingMessage new())
            sent = true
        }
        sender get("alive", Bool)
    }
    
}

PingMessage: class extends Message {}
PongMessage: class extends Message {}

