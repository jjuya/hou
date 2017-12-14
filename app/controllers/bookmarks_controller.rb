class BookmarksController < ApplicationController

  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to root_path
  end

  def show
    redirect_to root_path
  end

  def new
    redirect_to root_path
  end

  def create
    bookmark = Bookmark.create(bookmark_params)
    list = List.find(bookmark.list_id)

    if bookmark.save
      redirect_to board_path(list.board_id)
    else
      flash[:toastr] = { "error" => "Error: Not Create Bookmark" }
      redirect_to board_path(list.board_id)
    end
  end

  def edit
    redirect_to root_path
  end

  def update
    @bookmark.update(bookmark_params)

    list = List.find(@bookmark.list_id)

    if @bookmark.save
      redirect_to board_path(list.board_id)
    else
      flash[:toastr] = { "error" => "Error: Not Update Bookmark" }
      redirect_to board_path(list.board_id)
    end
  end

  def destroy
    @bookmark.destroy

    list = List.find(@bookmark.list_id)

    if @bookmark.save
      redirect_to board_path(list.board_id)
    else
      flash[:toastr] = { "error" => "Error: Not Destroy Bookmark" }
      flash[:error] = "Error: Not Destroy Bookmark"
      redirect_to board_path(list.board_id)
    end
  end

  private
  def set_bookmark
    @bookmark = Bookmark.find(params[:id])
  end

  def bookmark_params
     if params[:action].eql? "create"
       ext_tag(params[:bookmark][:url]).permit!
     else # when Edit
       params.require(:bookmark).permit(:title, :url, :description, :list_id, :tag_1, :tag_2, :tag_3, :rating)
     end

  end

  def ext_tag(url)

    iskorean = false

    # If there is no http://
    unless url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
      url = "http://#{url}"
    end

    value = check_url(url) # return "body name","tag name", "Mobile Mode"

    title_name = value[0]
    body_name = value[1]
    tag_name = value[2]
    mobile_mode = value[3]

    if mobile_mode
      url = url.gsub(url.partition("//")[1], url.partition("//")[1]+"m." )
    end
  # =======================================================================================

  # =================== Crawling ==========================================================
    # #crawling
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)

    # remove
    doc.css('script').remove
    doc.xpath("//@*[starts-with(name(),'on')]").remove

    title = doc.css(title_name).text
  # p title, title.nil?
    if title.eql? ""
      value = switch_tag(title)
      title_name = value[0]
      body_name = value[1]
      tag_name = value[2]
      title = doc.css(title_name).text
    end

    content = doc.css(body_name).text
    tag = doc.css(tag_name).text
  # p content, title, tag
    # Checking Korean
    iskorean = true if content.match(/[가-힣]+/)

    content = content.gsub("  ","")
    content = content.gsub("\n","")

    if iskorean
      all_text = content.split(/[\?\!\.;]+/)
      all_text.length.times do |i|
        l = all_text[i].strip
        if(l.length > 0)
          all_text[i] = l
        end
      end
      content = all_text
    end

    # p all_text
    # tag = Array.new
    tag = Hash.new

    # twitter KoNLP / TF-IDF model

    tag = iskorean ? kor_tag(content,title) : en_tag(content)

    unless url.include? 'youtube' or url.include? 'webtoon' or url.include? 'search.naver' or url.include? 'finance.naver'
      params[:bookmark][:tag_1] = tag.keys[0]
      params[:bookmark][:tag_2] = tag.keys[1]
      params[:bookmark][:tag_3] = tag.keys[2] unless tag.keys[2].nil?
    else
      params[:bookmark][:tag_1] = tf_idf(all_text, title)[0][0]
      params[:bookmark][:tag_2] = tf_idf(all_text, title)[1][0]
      params[:bookmark][:tag_3] = tf_idf(all_text, title)[2][0] if tf_idf(all_text, title).length >= 3
    end
    params[:bookmark][:title] = title
    return params[:bookmark]

  end

  # =============== English NLP ===========================================================
  def en_tag(content)
    content = content.gsub(/[#=><]+/,"")
    keywords = TextRank.extract_keywords(content)
    tag = Hash.new(0)
    keywords.keys.each do |k|
      tag.store(k, keywords[k])
    end
    return tag
  end

  # =============== Korean NLP ============================================================
  #     Warning It need to JAVA Install
  # ---------------------------------------------------------------------------------------
  def kor_tag(all_text, title)
    processor = TwitterKorean::Processor.new

    twitter = Array.new
    all_text.each do |s|
      twitter << processor.stem(s)
    end

    # hashtag
    metadata = Array.new
    twitter.length.times do |i|
      twitter[i].each do |t|
        metadata << t if t.metadata.pos == :hashtag # t.metadata
        # puts t.metadata
      end
    end

    # words_count
    word = Hash.new(0)
    twitter.length.times do |i|
      twitter[i].each do |t|
        if word.has_key? t
          word[t] += 1 if t.metadata.pos == :noun # :hasttag
        else
          word.store(t, 1) if t.metadata.pos == :noun
        end
      end
    end

    stop_words = ["씨", "오", "장", "생", "및", "메", "아래", "에서", "절", "좋은", "아주", "직접", "완전", "요", "노", "★", "정말", "도", "더", "본문", ">", "<", "화", "및", "위", "곳", "것", "값", "의", "이", "경우", "수", "있는", "가", "는", "을", "를", "하다", "이다", "할수있는", "하는", "하고", "있다", "박", "사용", "그리고", "그래서", "또는", "또한", "하지만", "등", "가지"]
    word.except!(*stop_words)
    word = word.sort_by {|k, v| v}.reverse.to_h
    # p word

    tag = Hash.new
    # tag = Array.new

    # word count를 기준으로 word count에서 tf-idf가 있는 단어는 꼭 뽑아오고
    # 그 외에는 word count를 가져오는 형식.
    # tf = tf_idf(all_text, title).rev
    tf_idf(all_text, title)[0..3].each do |i|
      word.keys[0..2].each do |j|
        if i[0] == j
          tag.store(i[0], i[1])
          p tag
        else
          tag.store(i[0], i[1])
          tag.store(j, word[j])
        end
      end
    end

    p tag
    return tag
  end

  def tf_idf(all_text, title)
    idf = Array.new
    stop_words = ["있는가?", "수", "무엇을", "할", "있는가", "및", "좋은", "★", ">", "<", "이것이", "것", "~", "!", ".", "조회", "위", "중", "수", "있는", "가", "는", "을", "를", "하다", "이다", "할수있는", "하는", "하고", "있다", "박", "사용", "그리고", "그래서", "또는", "또한", "하지만","이", "것"]
    all_text.each do |at|
      # puts at
      text = at
      tokens = UnicodeUtils.each_word(text).to_a - stop_words
      term_counts = Hash.new(0)
      size = 0
      tokens.each do |token|
        unless token[/\A\d+\z/]
          term_counts[token.gsub(/\p{Punct}/, '')] += 1
          size += 1
        end
      end
      idf << TfIdfSimilarity::Document.new(text, :term_counts => term_counts, :size => size)
    end
    idf << TfIdfSimilarity::Document.new(title)

    model = TfIdfSimilarity::TfIdfModel.new(idf, :library => :narray)

    tfidf_by_term = {}
    idf[-1].terms.each do |term|
      tfidf_by_term[term] = model.tfidf(idf[-1], term)
    end
    tf = tfidf_by_term.sort_by{|_,tfidf| -tfidf}.reverse
    p tf
    return tf
  end

  def check_url(url)
    #div_775
    crawl_hash= {
      # "cafe.naver"    => ["h2.tit","#ct",nil,true],
      "cafe.naver"    => ["h2.tit", "#postContent",nil,true],
      "blog.naver"    => ["h3.se_textarea",".__se_component_area",".post_tag",true],
      # "blog.naver"    => ["h3.tit_h3", "#viewTypeSelector", ".post_tag", true],
      "cafe.daum"     => ["h3.tit_subject","#daumWrap",nil,true],
      "blog.daum"     => ["h3.tit_view","#article","#tagListLayer_11777182",true],
      "stackoverflow" => ["title","#mainbar",nil,false],
      "/github"       => ["title","#readme","body",false],
      # ".github.io"    => ["title", "#content > div > article", nil, false],
      "brunch"        => ["title",".wrap_view_article",nil,false],
      "tistory"       => [".titleWrap","#body > div.article > div > div", ".tag_label", false],
      "search.naver"  => ["head > title", "#ct", nil, true]
    }

    def_val = ["title","body",nil,false] # crawl_hash에 지정되어 있지 않은 도메인의 url

    # "body name","tag name", "Mobile Mode"
    crawl_hash.each do |key, val|
      # p val[1]
      # p val[2]
      unless url[key].nil?
        val[-1] = false unless url["/m."].nil?
        #key가 crawo_hash에 있는 경우, key에 해당하는 val값이 return
        # p val
        return val
      end
    end

    return def_val
  end

  def switch_tag(title_tag)
    other_tags ={
      "h3.se_textarea" => ["#ct > div._postView > div.post_tit_area > div.tit_area.no_reply > h3","#viewTypeSelector","#ct > div._postView > div.post_tag"]
    }
    other_tags.each do |title, val|
      if title.eql? title_tag
        return val
      end
    end
    def_tag = ["title","body",nil]

    return def_tag
  end

end
