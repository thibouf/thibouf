-- MATH ; todo separate -----------------
function Normalize( x, y )
  s = 1 / math.sqrt( x * x + y * y)
  return x*s, y*s
end

function Mult( x, y , f )
    return x * f , y * f 
end

function Add( x1 , y1 , x2, y2 )
    return x1 + x2, y1 + y2 
end

function Rotate( x , y, angle )
    return x * math.cos( angle ) - y * math.sin( angle ),
           x * math.sin( angle ) + y * math.cos( angle )
end


function Rad2Vect( r )
    return math.cos( r ), math.sin( r )
end

function VectToRad( x, y )
    return math.atan2( x, -y ) - math.pi / 2
end
------------------------------------------
