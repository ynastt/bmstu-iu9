#include <glfw3.h>
#include <cmath>
#include <iostream>

const double PI = 3.141592653589793;
const int HEIGHT = 700;
const int WIDTH = 700;

float teta = 0; //z
float delta = 180; //y
float phi = -30; //x

void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    if (action == GLFW_PRESS || action == GLFW_REPEAT) {
        switch (key)
        {
        case GLFW_KEY_RIGHT:
            delta += 10;
            break;
        case GLFW_KEY_LEFT:
            delta -= 10;
            break;
        case GLFW_KEY_UP:
            phi += 10;
            break;
        case GLFW_KEY_DOWN:
            phi -= 10;
            break;
        case GLFW_KEY_ENTER:
            GLint rastMode[2];
            glGetIntegerv(GL_POLYGON_MODE, rastMode);
            if (rastMode[1] == GL_FILL) {
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            }
            else {
                glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
            }
            break;
        }
    }
}

void draw_cube(GLfloat posx, GLfloat posy, GLfloat posz, GLfloat d) {
    glBegin(GL_QUADS);   
    
    // Top face ( y + d/2)
    glColor3f(0.0f, 1.0f, 0.0f);     // Green
    glVertex3f(posx - d / 2, posy + d / 2, posz + d / 2);
    glVertex3f(posx - d / 2, posy + d / 2, posz - d / 2);
    glVertex3f(posx + d / 2, posy + d / 2, posz - d / 2);
    glVertex3f(posx + d / 2, posy + d / 2, posz + d / 2);
    
    // Bottom face (y - d/2)
    glColor3f(1.0f, 0.5f, 0.0f);     // Orange
    glVertex3f(posx - d / 2, posy - d / 2, posz + d / 2);
    glVertex3f(posx - d / 2, posy - d / 2, posz - d / 2);
    glVertex3f(posx + d / 2, posy - d / 2, posz - d / 2);
    glVertex3f(posx + d / 2, posy - d / 2, posz + d / 2);

    // Front face  (z + d/2)
    glColor3f(1.0f, 0.0f, 0.0f);     // Red
    glVertex3f(posx - d / 2, posy - d / 2, posz + d / 2);
    glVertex3f(posx - d / 2, posy + d / 2, posz + d / 2);
    glVertex3f(posx + d / 2, posy + d / 2, posz + d / 2);
    glVertex3f(posx + d / 2, posy - d / 2, posz + d / 2);

    // Back face (z - d/2)
    glColor3f(1.0f, 1.0f, 0.0f);     // Yellow
    glVertex3f(posx - d / 2, posy - d / 2, posz - d / 2);
    glVertex3f(posx - d / 2, posy + d / 2, posz - d / 2);
    glVertex3f(posx + d / 2, posy + d / 2, posz - d / 2);
    glVertex3f(posx + d / 2, posy - d / 2, posz - d / 2);

    // Left face (x - d/2)
    glColor3f(0.0f, 0.0f, 1.0f);     // Blue
    glVertex3f(posx - d / 2, posy - d / 2, posz - d / 2);
    glVertex3f(posx - d / 2, posy + d / 2, posz - d / 2);
    glVertex3f(posx - d / 2, posy + d / 2, posz + d / 2);
    glVertex3f(posx - d / 2, posy - d / 2, posz + d / 2);
    
    // Right face (x +d/2)
    glColor3f(1.0f, 0.0f, 1.0f);     // Magenta
    glVertex3f(posx + d / 2, posy - d / 2, posz - d / 2);
    glVertex3f(posx + d / 2, posy + d / 2, posz - d / 2);
    glVertex3f(posx + d / 2, posy + d / 2, posz + d / 2);
    glVertex3f(posx + d / 2, posy - d / 2, posz + d / 2);
    glEnd();  
}

int main(void) {
    const GLdouble m[16] = { 1, 0, 0, 0, 0, 1, 0, 0, -cos(PI / 4), -sin(PI / 4), -1, 0, 0, 0, 0, 1 };
   
    GLFWwindow* window;
    if (!glfwInit())
        return -1;

    window = glfwCreateWindow(WIDTH, HEIGHT, "lab2", NULL, NULL);
    if (!window) {
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);
    glfwSetKeyCallback(window, key_callback);
    
    glEnable(GL_DEPTH_TEST);
    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glMultMatrixd(m);
        glScalef(0.5, 0.5, 0.5);
        draw_cube(0, 0, 0, 0.5);
        
        glLoadIdentity();
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glPushMatrix();
        glRotatef(teta, 0, 0, 1);
        glRotatef(phi, 1, 0, 0);
        glRotatef(delta, 0, 1, 0);
        
        glScalef(0.5, 0.5, 0.5);
        draw_cube(-1.3, 0.1, -0.5, 0.5);
        glPopMatrix();
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    glfwTerminate();
    return 0;
}