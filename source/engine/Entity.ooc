import structs/[ArrayList, HashMap, Stack]
import Property, Update, Message

Entity: class {
    
    name: String
    id: Int
    
    props := HashMap<String, Property> new()
    updates : Update[]
    receivers : Receiver[]
    queue : Message[]
    
    idSeed := static 0
    
    init: func ~withName(=name) {
        This idSeed += 1
        id = This idSeed
    }
    
    addUpdate: func (update: Update) { updates add(update) }
    
    update: func {
        if(updates isEmpty()) return
        
        //printf("[%d] %s got %d updates to run\n", id, name, updates size())
        
        iter := updates iterator()
        while(iter hasNext()) {
            up := iter next()
            //printf("[%d] %s running update %s\n", id, name, up class name)
            if(!up run(this)) {
                iter remove()
            }
        }
        
        while(!queue isEmpty()) {
            msg := queue get(0)
            queue removeAt(0)
            for(r in receivers) {
                if(msg class == r messageType) {
                    r call(msg)
                }
            }
        }
    }
    
    listen: func (messageType: MessageClass, call: Func (Message)) {
        receivers add(Receiver new(messageType, call))
    }
    
    send: func (target: Entity, msg: Message) {
        msg sender = this
        msg target = target
        target queue add(msg)
    }
    
    // Generic properties convenience functions
    
    set: func <T> (name: String, value: T) {
        prop := props get(name)
        if(prop) {
            prop set(value)
        } else {
            prop := GenericProperty new(name, value)
            props put(name, prop)
        }
    }
    
    get: func <T> (name: String, T: Class) -> T {
        prop := props get(name)
        if(!prop) return null
        if(!prop instanceOf(GenericProperty)) {
            Exception new(This, "Attempting to get (%s, %s), but the property isn't generic but a %s" format(name, T name, prop class name)) throw()
        }
        gp := prop as GenericProperty<T>
        if(!gp T inheritsFrom(T)) {
            Exception new(This, "Attempting to get (%s, %s), but the property has incompatible type %s" format(name, T name, gp T name)) throw()
        }
        return gp get()
    }
    
}

Receiver: class {

    messageType: MessageClass
    call: Func (Message)
    
    init: func (=messageType, =call) {}
    
}
