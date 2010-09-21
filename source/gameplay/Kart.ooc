use sdl

import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Quad, Line, Camera, Texture]
import gfx/md5/MD5Loader, gfx/r2m/R2MModel

import sdl/[Core, Event]

import physics/[PhysicsEngine, Body, Box, Geometry]

import math

CameraMode: enum {
    THIRD_PERSON
    BIRDS_EYE
}

Kart: class extends Entity {

    model := MD5Loader load("data/models/tricycle/tricycle.md5mesh")
    bboxModel := Cube new("kart_bbox")
    body := Body new("kart_body")
    geom := Box new("kart_geom")
    camPos := Float3 new()

    maxSpeed := 230.0
    
    speed: Float {
        get {
            body vel length() / maxSpeed
        }
    }
    
    orientationAxis := Line new("kart_direction")
    velocityAxis := Line new("kart_velocity")
    axisLength := 25.0
    
    cam: Camera
    camMode := CameraMode THIRD_PERSON
    interpolate := true

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
                case SDLK_c     =>
                    if(val)
                        camMode = (camMode == CameraMode BIRDS_EYE) ? CameraMode THIRD_PERSON : CameraMode BIRDS_EYE
                case SDLK_i		=>
					if(val)
						interpolate = !interpolate
            }
        )
        
        set("maxSpeed", 180.0)
        set("turnSpeed", 1.3)
        
        set("cameraDistance", 14.0)
        set("cameraHeight", 11.0)
        set("cameraHeightBirdsEye", 300.0)
        set("cameraPhi", -15.0)
        
        set("brakeFactor", 0.8)

        body pos set(0, 0, 0.01)
    }

    update: func {
        super()
        
        maxSpeed := get("maxSpeed", Float)
        currentSpeed := dist(Float3 new(), body vel)
            
        if(brake) {
			brakeFactor := get("brakeFactor", Float)
			currentSpeed *= brakeFactor
		} if(accelerate) {
			if(speed < maxSpeed) currentSpeed += 10.0
        }
        if(brake || accelerate) {
			body vel set(
                body vel x * 0.9 + (cos(alpha / 180.0 * PI) * currentSpeed) * 0.1,
                body vel y * 0.9 + (sin(alpha / 180.0 * PI) * currentSpeed) * 0.1,
                0
            )
		}
        
        turnSpeed := get("turnSpeed", Float)
        actualTurnSpeed := turnSpeed * (1.0 - ((maxSpeed - currentSpeed) / maxSpeed * 0.3))
        
        if(turnLeft) {
            alpha += actualTurnSpeed
        } else if(turnRight) {
            alpha -= actualTurnSpeed
        }

        alphaRad := alpha / 180.0 * PI
        
        velDir := Float2 new(body vel x, body vel y)
        velDir normalize()
        
        unitDir := Float2 new(cos(alphaRad), sin(alphaRad))
        dot := velDir dot(unitDir)

		if(-1.0 < dot && dot < 1.0) {
            velNorm := body vel length()
            epsilon := 0.9
            body vel set(
                (body vel x * epsilon) + (unitDir x * velNorm * (1.0 - epsilon)),
                (body vel y * epsilon) + (unitDir y * velNorm * (1.0 - epsilon)),
                0
            )
        }
        
        body rot set(0.0, 0.0, alpha - 90)

        // now handle collisions
        level := engine getEntity("level") as R2MModel
        
        reaction := Float3 new()
        for(trackbound in level geometries) {
            if(geom collide(trackbound, reaction)) {
				/*
                ("Got a collision! geom pos = " + geom get("position", Float3) toString() +
                    ", geom rot = " + geom get("eulerAngles", Float3) toString() +
                    ", trackbound pos = " + trackbound get("position", Float3) toString() +
                    " reaction = " + reaction toString()) println()
                */
                body pos += reaction

				velDir = Float2 new(body vel x, body vel y)
                velDir normalize()

                reac2D := Float2 new(reaction x, reaction y)
                reac2D normalize()
                dot = velDir dot(reac2D)

                body vel -= (reaction * dot)
                body vel scale(body vel length() > (maxSpeed * 0.5) ? 0.7 : 0.97)

                break
            }
        }
        
        if(camMode == CameraMode THIRD_PERSON) {
            cameraDistance := get("cameraDistance", Float)
            cameraHeight := get("cameraHeight", Float)
            cameraPhi := get("cameraPhi", Float)

			camPos := cam get("position", Float3)
			camPos set(
				camPos x * 0.75 + (body pos x - cos(alpha / 180.0 * PI) * cameraDistance) * 0.25,
				camPos y * 0.75 + (body pos y - sin(alpha / 180.0 * PI) * cameraDistance) * 0.25,
				cameraHeight
			)
    
            cam theta = (cam theta * 0.8) + (alpha * 0.2)
            cam phi = cameraPhi
            cam vectorsFromAngles()
        } else if(camMode == CameraMode BIRDS_EYE) {
            cameraHeightBirdsEye := get("cameraHeightBirdsEye", Float)
            
            cam get("position", Float3) set(
                body pos x,
                body pos y,
                cameraHeightBirdsEye
            )

            cam theta = alpha
            cam phi = -90
            cam vectorsFromAngles()
        }

        if(alpha < 0) {
            alpha += 360.0
            cam theta += 360.0
        }
        if(alpha > 360.0) {
            alpha -= 360.0
            cam theta -= 360.0
        }
    }
    
    onAdd: func {
        engine scene addModel(model)
        
        cam = engine getEntity("default_cam") as Camera
        cam set("sensitivity", 0)
        cam set("speed", 0)
        
        physx := engine getEntity("physx") as PhysicsEngine
        physx add(body, model)

        // add and bind the bounding box
        engine scene addModel(bboxModel)
        bboxModel set("scale", Float3 new(6.0, 6.0, 6.0))
        bboxModel show = false
        body pos bind(bboxModel pos)
        body rot bind(bboxModel rot)

        // bind the geom
        body pos bind(geom get("position", Float3))
        body rot bind(geom get("eulerAngles", Float3))
        geom get("scale", Float3) set(bboxModel get("scale", Float3))
    }

}

