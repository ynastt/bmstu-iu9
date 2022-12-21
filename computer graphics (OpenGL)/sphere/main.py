# шар 
import math
from functools import lru_cache

import glfw
from OpenGL.GL import *

window = None
alpha = 0.0
beta = 0.0
gamma = 0.0
polygonMode = True


def main():
    global window

    if not glfw.init():
        return
    window = glfw.create_window(640, 640, "Lab3", None, None)
    if not window:
        glfw.terminate()
        return

    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    glEnable(GL_DEPTH_TEST)
    while not glfw.window_should_close(window):
        display()
    glfw.destroy_window(window)
    glfw.terminate()


def key_callback(window, key, scancode, action, mods):
    global alpha, beta, gamma, polygonMode
    if action == glfw.PRESS:
        if key == glfw.KEY_RIGHT:
            gamma += 5
        if key == glfw.KEY_LEFT:
            gamma -= 5
        if key == glfw.KEY_UP:
            alpha -= 5
        if key == glfw.KEY_DOWN:
            alpha += 5
        if key == glfw.KEY_SPACE:
            polygonMode = not polygonMode


def torus(n):
    glBegin(GL_TRIANGLE_STRIP)
    glColor4f(0.0, 0.0, 0.75, 0.5)
    for theta in range(n):
        for phi in range(n):
            glVertex3f(*get_coord(0.5, 0.03, theta/n*2*math.pi, phi/n*2*math.pi))

    glEnd()


def get_coord(R, r, theta, phi):
    x = math.cos(theta) * math.cos(phi)#(R + r * math.cos(theta)) * math.cos(phi)
    y = math.sin(theta) * math.cos(phi)#(R + r * math.cos(theta)) * math.sin(phi)
    z = math.sin(phi)#0.25 * math.sin(theta)
    return x, y, z


def display():
    global alpha, beta, gamma, polygonMode
    glPolygonMode(GL_FRONT, GL_FILL if polygonMode else GL_LINE)

    glClearColor(1.0, 1.0, 1.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glPolygonMode(GL_FRONT, GL_LINE)

    glLoadIdentity()
    glRotated(100 + alpha, 1, 0, 0)
    glRotated(-30 + gamma, 0, 0, 1)
    torus(100)



    glfw.swap_buffers(window)
    glfw.poll_events()


main()