object false
node(:event_types) { event_types }
node(:clans) { user_clans }
node(:games) { user_games }
node(:psn_user_name) {current_user.psn_user_name}
node(:xbox_live_user_name) {current_user.xbox_live_user_name}
node(:nintendo_user_name) {current_user.nintendo_user_name}
node(:battle_user_name) {current_user.battle_user_name}
node(:origins_user_name) {current_user.origins_user_name}
node(:steam_user_name) {current_user.steam_user_name}
node(:game_types) { User::GAME_TYPE }
node(:play_types) { User::GAME_STYLE }
node(:durations) { Event::DURATIONS }
node(:allow_waitlists) { Event::WAITLIST }
node(:users) { users }

node(:ages) { (13..99).map{|v| [v,v]} }
node(:subscription) { subscription_plan }
