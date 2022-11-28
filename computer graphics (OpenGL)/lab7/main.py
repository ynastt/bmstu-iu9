import glfw
from OpenGL.GL import *
from OpenGL.GLUT import *
import math
import numpy as np
from PIL import Image
import time

window_width = 500
window_height = 500
scale = 0.7

animation_mode = False
texture_sides = None

textureCoordinates = ((0, 0), (0, 1), (1, 1), (1, 0))

x_angle = 0
y_angle = 0
accuracy = 30
a = 0.5
b = 0.8

flying_speed = 0
V = 0.0009
acl = 0.00006

light_mode = False
texture_mode = 1
filling_mode = True

array_bot = []
array_side = []
array_color = []


def draw_wall():
    glLineWidth(5.0)
    glBegin(GL_LINES)
    glColor4f(1.0, 0.0, 0.0, 1.0)  # x - red
    glVertex3f(1.0, 0.65, 0.0)
    glVertex3f(-1.0, 0.65, 0.0)
    glEnd()
    glBegin(GL_LINES)
    glColor4f(1.0, 0.0, 0.0, 1.0)  # x - red
    glVertex3f(1.0, -0.7, 0.0)
    glVertex3f(-1.0, -0.7, 0.0)
    glEnd()


def main():
    if not glfw.init():
        return
    window = glfw.create_window(window_width, window_height, "Lab6", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    glfw.set_mouse_button_callback(window, mouse_callback)
    generate_texture()
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    glEnableClientState(GL_VERTEX_ARRAY)
    glEnableClientState(GL_COLOR_ARRAY)
    if texture_mode > 0:
        glEnableClientState(GL_TEXTURE_COORD_ARRAY)
    make_vertices()
    init_second_display_list()
    init_first_display_list()
    glCallList(1)
    start = time.monotonic()
    # while glfw.get_key(window, glfw.KEY_ESCAPE) != glfw.PRESS and not glfw.window_should_close(window):
    for _ in range(200):
        display()
        glfw.swap_buffers(window)
        glfw.poll_events()
    glfw.destroy_window(window)
    glfw.terminate()


def display():
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glLoadIdentity()
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    draw_wall()
    glLineWidth(1.0)
    if animation_mode:
        move_object()

    glScale(scale, scale, scale)

    global accuracy, a, b, texture_mode
    glPushMatrix()
    glTranslatef(0, flying_speed, 0)
    glRotatef(x_angle, 1, 0, 0)
    glRotatef(y_angle, 0, 1, 0)

    glCallList(2)
    glShadeModel(GL_FLAT)
    glPopMatrix()


def key_callback(window, key, scancode, action, mods):
    global x_angle, y_angle, scale, animation_mode
    if action == glfw.PRESS and key == glfw.KEY_ENTER:
        mode = glGetIntegerv(GL_POLYGON_MODE)
        if mode[1] == GL_LINE:
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
        else:
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    if action == glfw.PRESS or action == glfw.REPEAT:
        if key == glfw.KEY_A:
            y_angle -= 2
        if key == glfw.KEY_D:
            y_angle += 2
        if key == glfw.KEY_W:
            x_angle -= 2
        if key == glfw.KEY_S:
            x_angle += 2
        if key == glfw.KEY_UP:
            scale += 0.05
        if key == glfw.KEY_DOWN:
            scale -= 0.05
        global light_mode
        if key == glfw.KEY_L:
            if glIsEnabled(GL_LIGHTING):
                glDisable(GL_LIGHTING)
            else:
                glEnable(GL_LIGHTING)
            return
        if key == glfw.KEY_M:
            animation_mode = not animation_mode
            return


def mouse_callback(window, button, action, mods):
    global filling_mode, texture_mode
    if action == glfw.PRESS:
        if button == glfw.MOUSE_BUTTON_LEFT:
            filling_mode = not filling_mode
            if filling_mode:
                glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
            else:
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
        elif button == glfw.MOUSE_BUTTON_RIGHT:
            texture_mode = not texture_mode
            if texture_mode:
                glBindTexture(GL_TEXTURE_2D, texture_sides)
            else:
                glBindTexture(GL_TEXTURE_2D, 0)


def move_object():
    global V, flying_speed, acl
    flying_speed -= V
    V += acl
    if flying_speed < - 1 or flying_speed > 0:
        V = -V


def generate_texture():
    global texture_mode
    texture_mode = glGenTextures(1)
    glBindTexture(GL_TEXTURE_2D, texture_mode)
    image = Image.open("texture.jpg")
    data_sides = np.array(list(image.getdata()), np.uint8)
    texture_sides = glGenTextures(1)
    glBindTexture(GL_TEXTURE_2D, texture_sides)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.width, image.height, 0, GL_RGB, GL_UNSIGNED_BYTE, data_sides)
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
    glEnable(GL_TEXTURE_2D)


#   light display list
def init_first_display_list():
    glNewList(1, GL_COMPILE)
    glEnable(GL_LIGHTING)
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, [[0.2, 0.2, 0.2, 1]])
    glLightfv(GL_LIGHT0, GL_AMBIENT, [0, 0, 0, 1])  # фоновое излучение
    glLightfv(GL_LIGHT0, GL_DIFFUSE, [0.4, 0.7, 0.2, 1])  # рассеяное излучение
    glLightfv(GL_LIGHT0, GL_SPECULAR, [1, 1, 1, 1])  # зеркальное излучение
    glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, [1, 1, 1, 1])
    glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, 50.0)
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, [0, 0, 0, 1])
    glLightfv(GL_LIGHT0, GL_POSITION, [1, 1, 0, 0])
    # первый светит белым направленным
    glLightfv(GL_LIGHT1, GL_POSITION, [0, 10, 0.1, 1])
    glLightfv(GL_LIGHT1, GL_DIFFUSE, [0, 0, 0, 0])
    glLightfv(GL_LIGHT1, GL_SPECULAR, [1, 1, 1, 1])
    glEnable(GL_LIGHT0)
    glEnable(GL_LIGHT1)
    glEnable(GL_LIGHT2)
    glDisable(GL_NORMALIZE)
    glEnable(GL_COLOR_MATERIAL)
    glLightf(GL_LIGHT2, GL_CONSTANT_ATTENUATION, 0.0)
    glLightf(GL_LIGHT2, GL_LINEAR_ATTENUATION, 0.2)
    glLightf(GL_LIGHT2, GL_QUADRATIC_ATTENUATION, 0.4)
    glEndList()


def init_second_display_list():
    glNewList(2, GL_COMPILE)
    glVertexPointer(3, GL_FLOAT, 0, array_side)
    glColorPointer(3, GL_FLOAT, 0, array_color)
    glTexCoordPointer(3, GL_FLOAT, 0, textureCoordinates)
    glDrawArrays(GL_TRIANGLE_FAN, 0, accuracy + 2)
    glVertexPointer(3, GL_FLOAT, 0, array_bot)
    glDrawArrays(GL_TRIANGLE_FAN, 0, accuracy + 2)
    glEndList()


def make_vertices():
    step = 2.0 * math.pi / accuracy
    color = [1.0, 1.0, 1.0]
    array_bot.append([0.0, 0.0, 0.0])
    array_color.append(color)
    for i in range(accuracy + 1):
        ang = i * step
        v = [a * math.cos(ang), 0.0, b * math.sin(ang)]
        array_bot.append(v)
        array_color.append(color)
    array_side.append([0.0, 0.9, 0.0])
    for i in range(accuracy + 1):
        ang = i * step
        v = [a * math.cos(ang), 0.0, b * math.sin(ang)]
        array_side.append(v)


start = time.monotonic()
main()
stop = time.monotonic()
print('optimized:', stop-start)
