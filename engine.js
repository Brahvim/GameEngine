class Scene {
    constructor() {
        this.entities = [];
    }

    setup() {
        for (let e of this.entities)
            e.setup();
    }

    update() {
        console.log("Updating scene...");
        for (let e of this.entities)
            e.update();
    }

    addEntities(p_entity) {
        this.entities.push(p_entity);
    }
}


class Entity {
    constructor() {
        this.id = -1;
        currentScene.entities.push(this);
    }

    setup() { }
    update() { }
    render() { }
}


function setScene(p_scene) {
    // The `Entity()` constructor needs this to take place first:
    currentScene = p_scene;
    p_scene.setup();
}

let currentScene;

let scene = new Scene();
currentScene = scene;

let player = new Entity();
player.setup = function () {
};

player.update = function () {
};

player.render = function () {
};

currentScene.setup();
// setScene(scene);
console.log(currentScene);



// p5.js:
function setup() {
    createCanvas(800, 600, WEBGL);
}

function draw() {
    push();
    currentScene.update();
    pop();

    for (let e of currentScene.entities)
        e.render();
}

draw();