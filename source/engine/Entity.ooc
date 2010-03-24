import structs/[ArrayList, HashMap, Stack]
import Property, Update, Message

Entity: class {
    
    name: String
    id: Int
    
    props := HashMap<String, Property> new()
    updates : Update[]
    receivers : Receiver[]
    queue := Stack<Message> new()
    
    idSeed := static 0
    
    init: func ~withName(=name) {
        This idSeed += 1
        id = This idSeed
    }
    
    addUpdate: func (update: Update) { updates add(update) }
    
    update: func {
        //printf("[%d] %s got %d updates to run\n", id, name, updates size())
        iter := updates iterator()
        while(iter hasNext()) {
            if(!iter next() run(this)) {
                iter remove()
            }
        }
        
        while(!queue isEmpty()) {
            msg := queue pop()
            for(r in receivers) {
                if(msg class == r messageType) {
                    r call(msg)
                }
            }
        }
    }
    
    receive: func (messageType: MessageClass, call: Func (Message)) {
        receivers add(Receiver new(messageType, call))
    }
    
    send: func (dest: Entity, msg: Message) {
        msg sender = this
        dest queue push(msg)
    }
    
}

Receiver: class {

    messageType: MessageClass
    call: Func (Message)
    
    init: func (=messageType, =call) {}
    
}
