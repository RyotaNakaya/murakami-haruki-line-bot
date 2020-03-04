require 'line/bot'

class WebhookController < ApplicationController
  protect_from_forgery except: [:callback] # CSRF対策無効化

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head 470
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: haruki_message(event.message['text'])
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    }
    head :ok
  end
end

def haruki_message(t)
  haruki_goroku = [
    "完璧な#{t}などといったものは存在しない。完璧な絶望が存在しないようにね。",
    "みんな同じさ。#{t}を持ってるやつはいつか失くすんじゃないかとビクついてるし、#{t}を持ってないやつは永遠に#{t}を持てないんじゃないんじゃないかと心配してる。",
    "強い#{t}なんてどこにも居やしない。強い振りのできる#{t}が居るだけさ。",
    "あらゆる#{t}は通りすぎる。誰にもそれを捉えることはできない。僕たちはそんな風にして生きている。",
    "遠くから見れば、大抵の#{t}は綺麗に見える。",
    "しかしそれと同時に#{t}なんてそもそも存在しないと言うこともできる",
    "俺は#{t}が好きなんだよ。苦しさやつらさも好きだ。夏の光や風の匂いや蝉の声や、そんなものが好きなんだ。どうしようもなく好きなんだ。",
    "本当にいいものはとても少ない。何でもそうだよ。#{t}でも、映画でも、コンサートでも、本当にいいものは少ない。",
    "こういう#{t}というのは一生に一度しかないことなんだって。そういうのってね、わかるんですよ、ちゃんと。",
    "そして今日でもなお、日本人の#{t}に対する意識はおそろしく低い。要するに、歴史的に見て#{t}が生活のレベルで日本人に関わったことは一度もなかったんだ。#{t}は国家レベルで米国から日本に輸入され、育成され、そして見捨てられた。それが#{t}だ。",
    "「どうせ#{t}の話だろう」とためしに僕は言ってみた。言うべきではなかったのだ。受話器が氷河のように冷たくなった。",
    "とにかく、そのようにして#{t}をめぐる冒険が始まった。",
    "「世界中の#{t}がみんな溶けて、バターになってしまうくらい好きだ」と僕は答えた。",
    "#{t}には優れた点が二つある。まずセックス・シーンの無いこと、それから一人も人が死なないことだ。",
    "他人とうまくやっていくというのはむずかしい。#{t}か何かになって一生寝転んで暮らせたらどんなに素敵だろうと時々考える。",
    "#{t}は生の対極にあるのではなく、我々の生のうちに潜んでいるだ",
  ]

  haruki_goroku.sample()
end
