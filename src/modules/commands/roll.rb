module Bot
  module Commands
    # command rolls dice, needs to be input in XdXX(+-X), with X being a number
    # and (being optional)
    module Roll
      extend Discordrb::Commands::CommandContainer
      command(:roll, description: "roll up to 20 dice\nusage: #{Pre::FIX}roll `NdN+-N`") do |event, dice_message|
        # process
        if dice_message =~ /[0-9]+d[0-9]+((\+|-)[0-9])?/
          # vars
          roll_math = true # positive if true, negative if false, irrelevant if
          # not greater than 4
          input = dice_message.split(/(d|\+|-)/)
          rolls = []
          total = 0
          output = ''

          # string processing
          roll_math = false if input[3] == '-'

          input = input.keep_if { |a| a =~ /[0-9]/ }
          input[0] = input[0].to_i
          input[1] = input[1].to_i
          input[2] = if input.size <= 2
                       0
                     else
                       input[2].to_i
                     end

          # failure states
          if input[0] <= 0 || input[0] > 20
            event.send_message('hey pal, try and roll a number from 1 to 20 instead :v')
          elsif input[1] <= 1 || input[1] > 120
            event.send_message('hey pal, try and roll a die from 2 to 120 instead :v')
          else
            # math
            rolls = Array.new(input[0])
            output = '`'
            rolls.each_index do |roll|
              rolls[roll] = rand(input[1]) + 1
              total += rolls[roll]
              output += "|#{rolls[roll].to_s.center(3)}|"
              output += "\t" if roll % 5 != 4
              output += "`\n`" if roll % 5 == 4
            end
            output += '`'

            if output.end_with?('``')
              output.slice!((output.length - 2)...(output.length))
            end

            mod_out = '+'
            if roll_math
              total += input[2]
            else
              total -= input[2]
              mod_out = '-'
            end
            # output
            event.channel.send_embed do |embed|
              embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "🎲 | #{dice_message}")
              embed.add_field(name: 'Rolls', value: output.to_s, inline: true)
              embed.add_field(name: 'Modifier', value: "#{mod_out}#{input[2]}", inline: true)
              embed.add_field(name: 'Results', value: total.to_s, inline: true)
            end
          end
        else
          event.send_message('please write that again in XXdXX format :U')
        end
      end
    end
  end
end
