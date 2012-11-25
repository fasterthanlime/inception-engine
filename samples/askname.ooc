import engine/[Engine, Entity, Property, Update]
import gfx/RenderWindow

main: func {
    
    engine := Engine new()
    
    engine addEntity(RenderWindow new(800, 600, 32, false, "AskName test."))
    
    player :=   Entity new("Player") \
        .addUpdate(Update new(func -> Bool {
            "username: " print()
            fflush(stdout)
            s := String new(128)
            scanf("%s", s)
            
            "Hi there, %s" format(s) println()
            false
        }))
    engine addEntity(player)
    engine run()
    
}
