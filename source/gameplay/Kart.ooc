use sdl

import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Quad, Line, Camera, Texture]
import gfx/md5/MD5Loader

import sdl/[Sdl, Event]

import physics/[PhysicsEngine, Body]

import math

Kart: class extends Entity {

    model := MD5Loader load("data/models/tricycle/tricycle.md5mesh")
    body := Body new("kart_body")
    
    cam: Camera

    alpha := 0.0

    turnLeft := false
    turnRight := false
    accelerate := false
    brake := false

    init: func {
        super("kart")

        listen(KeyboardMsg, |_m|
            m := _m as KeyboardMsg

            if(m type != SDL_KEYUP && m type != SDL_KEYDOWN) return

            val := (m type == SDL_KEYDOWN)
            match(m key) {
                case SDLK_UP    => accelerate = val
                case SDLK_DOWN  => brake      = val
                case SDLK_LEFT  => turnLeft   = val
                case SDLK_RIGHT => turnRight  = val
            }
        )
    }

    update: func {
        super()

        if(turnLeft) {
            alpha += 2.0
        } else if(turnRight) {
            alpha -= 2.0
        }

        if(accelerate) {
            "Accelerating!" println()
            speed := 150
            
            body vel set(
                cos(alpha * PI / 180.0) * speed,
                sin(alpha * PI / 180.0) * speed,
                0
            )
        }

        if(alpha < 0)     alpha += 360.0
        if(alpha > 360.0) alpha -= 360.0
        
        body rot set(0.0, 0.0, alpha - 90)

        cameraDistance := 40
        cameraHeight := 30
        
        cam get("pos", Float3) set(
            body pos x - cos(alpha * PI / 180.0) * cameraDistance,
            body pos y - sin(alpha * PI / 180.0) * cameraDistance,
            cameraHeight
        )

        cam theta = alpha
        cam phi = -25
        cam vectorsFromAngles()
    }
    
    onAdd: func {
        engine scene addModel(model)
        cam = engine getEntity("default_cam") as Camera
        physx := engine getEntity("physx") as PhysicsEngine
        physx add(body, model)
    }

}

