local rooms = require('saolei.rooms')

return function(sess)
    if sess.game.roomid then
        local room = rooms[sess.game.roomid]
        if sess.game.deskid then
            local desk = room.desks[sess.game.deskid]
            if desk then
                desk.users[sess.id] = nil
                desk.usern = desk.usern - 1
                for _, s in pairs(room.users) do
                    s.cast('cast.saolei.desk.update', { id = sess.game.deskid, usern = desk.usern })
                end
            end
        end
        room.users[sess.id] = nil
    end
end
