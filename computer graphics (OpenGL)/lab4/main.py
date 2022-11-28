import glfw
from OpenGL.GL import *
from OpenGL.GLU import *
import numpy
from scipy import signal

width = 640
height = 640
barrier = width // 2


def sign(x):
    if x > 0:
        return 1
    elif x < 0:
        return -1
    else:
        return 0


def to_pixels(c1, c2):
    return int(c1 * width / 2 + width / 2), int(c2 * height / 2 + height / 2)


def from_pixels(c1, c2):
    return (-1) + (c1 / width) * 2, (-1) * ((-1) + (c2 / height)*2)


class Polygon:
    def __init__(self):
        self.num = 0
        self.points = []
        self.point_before = []
        self.point_after = []
        self.filled = False
        self.filtered = False
        self.barrier = width // 2
        self.pixels = numpy.ones([width, height, 3], dtype=GLfloat)     # многомерный массив вида [(640, 640, 3), ...]

    def clear(self):
        self.points = []

    def add_point(self, new_point):
        self.points.append(new_point)
        self.num += 1

    def pop_point(self, new_point):
        self.points.pop(self.num-1)
        self.num -= 1

    def filter(self):
        ker = (1 / 18) * numpy.array([[2, 2, 2], [2, 2, 2], [2, 2, 2]], dtype='float')
        for i in range(self.pixels.shape[2]):
            self.pixels[:, :, i] = signal.convolve2d(numpy.pad(self.pixels[:, :, i], 1), ker, 'valid')

    def display(self):
        self.pixels = numpy.ones([width, height, 3], dtype=GLfloat)
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        #   зададим границы области просмотра от -1 до 1
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        gluOrtho2D(-1.0, 1.0, -1.0, 1.0)    # определяет матрицу двухмерной ортогональной проекции
        #   рисуем
        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity()
        self.drawing_through_points()
        if self.filtered:
            self.filter()
        # datta = self.pixels.reshape(width * height * 3)
        rawdata = numpy.ascontiguousarray(self.pixels)
        data = rawdata.reshape(width * height * 3)
        # пишет блок пикселей в буфер кадров
        glDrawPixels(width, height, GL_RGB, GL_FLOAT, (GLfloat * len(data))(*data))

    #   дополняем цвет пикселей
    def inverting(self, x, y):
        if x > barrier:    # правее перегородки и левее грани
            self.pixels[y, self.barrier:x, :] = 1 - self.pixels[y, self.barrier:x, :]
        else:                   # левее перегородки и правее грани
            self.pixels[y, x:self.barrier, :] = 1 - self.pixels[y, x:self.barrier, :]

    def bresenham(self, x1, y1, x2, y2):
        dx = abs(x2 - x1)
        dy = abs(y2 - y1)
        sign_x = sign(x2 - x1)
        sign_y = sign(y2 - y1)

        if dx > dy:
            pdx = sign_x
            pdy = 0
            es = dy
            el = dx
        else:
            pdx = 0
            pdy = sign_y
            es = dx
            el = dy

        x = x1
        y = y1
        er = el / 2
        self.pixels[y, x, :] = [0, 0, 0]
        if self.filled and ((self.point_after[1] - y) * (self.point_before[1] - y)) > 0:
            self.inverting(x, y)
        k = 0
        y0 = y
        while k < el:
            er -= es
            if er < 0:
                er += el
                x += sign_x
                y += sign_y
            else:
                x += pdx
                y += pdy
            k += 1
            self.pixels[y, x, :] = [0, 0, 0]
            if self.filled and y0 != y:
                self.inverting(x, y)
            y0 = y

    def drawing_through_points(self):
        length = len(self.points)
        if length != 0:
            self.point_before = to_pixels(*self.points[-1])
        for i in range(length):
            if i == length - 1:                          # начальная точка = последняя точка
                x0, y0 = to_pixels(*self.points[i])
                x1, y1 = to_pixels(*self.points[0])
            else:                                       # от x0 до x1
                x0, y0 = to_pixels(*self.points[i])
                x1, y1 = to_pixels(*self.points[i + 1])

            self.point_after = [x1, y1]                 # следующая точка
            self.bresenham(x0, y0, x1, y1)              # соединяем
            self.point_before = [x0, y0]                # сохраняем текущую точку


polygon = Polygon()


def mouse_callback(window, button, action, mods):
    if action == glfw.PRESS:
        if button == glfw.MOUSE_BUTTON_LEFT:
            x, y = glfw.get_cursor_pos(window)
            point = [*from_pixels(x, y)]
            polygon.add_point(point)
        if button == glfw.MOUSE_BUTTON_RIGHT:
            x, y = glfw.get_cursor_pos(window)
            point = [*from_pixels(x, y)]
            polygon.pop_point(point)


def key_callback(window, key, scancode, action, mods):
    if action == glfw.PRESS:
        if key == glfw.KEY_C:                       # clear
            polygon.clear()
            polygon.filled = False
            polygon.filtered = False
        elif key == glfw.KEY_R:                     # raster
            polygon.filled = True
            polygon.drawing_through_points()
        elif key == glfw.KEY_F:                     # filtration
            polygon.filtered = True
            polygon.filter()


def main():
    if not glfw.init():
        exit()
    window = glfw.create_window(width, height, "Lab4", None, None)
    if not window:
        glfw.terminate()
        exit()
    glfw.make_context_current(window)
    glfw.set_mouse_button_callback(window, mouse_callback)
    glfw.set_key_callback(window, key_callback)
    glViewport(0, 0, width, height)

    while glfw.get_key(window, glfw.KEY_ESCAPE) != glfw.PRESS and not glfw.window_should_close(window):
        polygon.display()
        glfw.swap_buffers(window)
        glfw.poll_events()

    glfw.destroy_window(window)
    glfw.terminate()


if __name__ == '__main__':
    main()
