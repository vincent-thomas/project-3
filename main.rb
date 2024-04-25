require "ruby2d"

set background: "green"

def change_index(index, arr_len)
  index += 1
  if index > arr_len
    index = 0
  end
  return index
end


class NewtonGravity
  attr_accessor :mass, :x, :y
  def initialize(x:, y:)
    @y = y
    @x = x
    @mass = 10**6
    @g = 9.81
    @inner_circle = Circle.new(
      x: @x,
      y: @y,
      radius: 8,
      sectors: 32,
      color: 'black',
      z: 30
    )
  end
  def get_x
    return @x
  end

  def get_y
    return @y
  end
end

def calculate_force(m1, m2, r)
  r2 = r**2
  stora_G = 6.67*10**-11
  return stora_G*(m1*m2)/(r**2)
end


class Player
  attr_accessor :x, :y, :mass
  def initialize(x:, y:, friction:)
    @externaly_affected_render = false
    @color = 'red'
    @mass = 10000
    @speed = 0
    @y = y
    @x = x
    @delta_x = 0
    @delta_y = 0
    @friction = friction
    @inner_circle = Circle.new(
      x: @x,
      y: @y,
      radius: 8,
      sectors: 32,
      color: @color,
      z: 30
    )
  end

  def move(delta_x, delta_y)
    @delta_x = delta_x
    @delta_y = delta_y
  end
  def affect(delta_x, delta_y)
    @externaly_affected_render = true
    @delta_x = delta_x
    @delta_y = delta_y
  end


  def render_inner_circle
    @inner_circle.x = @x + @delta_x
    @inner_circle.y = @y + @delta_y
    @inner_circle.color = @color
  end

  def update_delta_for_each_render()
    if @externaly_affected_render == false
      @delta_x = @delta_x * @friction
      @delta_y = @delta_y * @friction
    end
  end

  def set_color(color)
    @color = color
  end

  def render()

    # x = kraft radien formeln => kraft
    # vektor_kraft_x_komposant = kraft * cos(atan(dy/dx))
    # @x += vektor_kraft_x_komposant

    if !(@delta_y.abs < 0.5 && @delta_x.abs < 0.5)
      @x += @delta_x
      @y += @delta_y

      self.update_delta_for_each_render()
    end
    self.render_inner_circle()


    @externaly_affected_render = false
  end

  def derender
    @inner_circle.remove()
  end
end

line = Line.new(
  x1: 125, y1: 100,
  x2: 350, y2: 400,
  width: 25,
  color: 'red',
  z: 20
)

line.remove

gravity = NewtonGravity.new(x: 200, y: 200)

players = []

players.push(Player.new(x: 150, y: 150, friction: 0.9))
# players.push(Player.new(x: 180, y: 120))
# players.push(Player.new(x: 200, y: 190))

index = 0

text = Text.new(
  "#{index+1} Player turn",
  x: 50, y: 50,
  style: 'bold',
  size: 20,
  color: 'black',
  rotate: 0,
  z: 10
)

update do
  # if players[0].get_x() > Window.width
  #   players[0].move(speed: players[0].get_speed() - 2, angle_degrees: 180 + players[0].get_angle() * 180 / Math::PI)
  # end

  # if players[0].get_x() < 0
  #   players[0].move(speed: players[0].get_speed() - 2, angle_degrees: 180 + players[0].get_angle() * 180 / Math::PI)
  # end

  players.each do |player|

    if player.x > Window.width
      new_angle = 360 - (player.get_angle() * 180 / Math::PI + 180)
      player.move(speed: player.get_speed() , angle_degrees: new_angle)
    end

    if player.y > Window.height
      # NOT WORKING
      new_angle =  360 - (player.get_angle() * 180 / Math::PI)
      player.move(speed: player.get_speed(), angle_degrees: new_angle)
    end


    if player.y < 0
      angle_degree = (player.get_angle() * 180 / Math::PI)

      player.move(speed: player.get_speed(), angle_degrees: angle_degree)
    end

    distance_between_closest_gravity = Math.sqrt((gravity.x-player.x)**2+(gravity.y-player.y)**2)
    if distance_between_closest_gravity < 100
      force_x = calculate_force(player.mass, gravity.mass, gravity.x-player.x)
      force_y = calculate_force(player.mass, gravity.mass, gravity.y-player.y)

      player.affect(force_x, force_y)
    end

    player.render()
  end
end


predict_drag = Circle.new(
      x: 0,
      y: 0,
      radius: 4,
      sectors: 32,
      color: "white",
      z: 30
    )

predict_drag.remove()

base_drag_x = nil
base_drag_y = nil

on :mouse do |event|
  if event.type == :down && !(base_drag_x && base_drag_y)
    base_drag_x = event.x
    base_drag_y = event.y
  end

  if event.type == :move && base_drag_x && base_drag_y

    minus_draggable_point_x = players[index].x - event.x
    minus_draggable_point_y = players[index].y - event.y

    puts minus_draggable_point_x, minus_draggable_point_x

    predict_drag.add

    predict_drag.x = minus_draggable_point_x + base_drag_x
    predict_drag.y = minus_draggable_point_y + base_drag_y
  end

  if event.type == :up

    predict_drag.remove()

    dragged_x = base_drag_x - event.x
    dragged_y = base_drag_y - event.y

    if dragged_x != 0 && dragged_y != 0
      players[index].move(dragged_x / 10, dragged_y / 10)

      players[index].set_color('red')

      index = change_index(index, players.length - 1)
      players[index].set_color('blue')

      text.text = "#{index+1} Player turn"

      base_drag_x = nil
      base_drag_y = nil
    end
  end
end

show
