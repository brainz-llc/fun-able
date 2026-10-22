require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "replaces each blank marker with the blank span" do
    card = Card.new(card_type: :black, content: "Nunca pensé en _____ hasta _____.")

    html = card_content_with_blanks(card, blank_class: "blank")

    assert_equal 2, html.scan('<span class="blank"></span>').size
    assert_includes html, "Nunca pensé en "
  end

  test "escapes author-supplied card content" do
    card = Card.new(card_type: :black, content: "<script>alert(1)</script> _____")

    html = card_content_with_blanks(card, blank_class: "blank")

    assert_not_includes html, "<script>"
    assert_includes html, "&lt;script&gt;alert(1)&lt;/script&gt;"
    assert_includes html, '<span class="blank"></span>'
  end

  test "escapes content that has no blank marker" do
    card = Card.new(card_type: :white, content: '"><img src=x onerror=alert(1)>')

    html = card_content_with_blanks(card, blank_class: "blank")

    assert_not_includes html, "<img"
    assert_includes html, "&lt;img src=x onerror=alert(1)&gt;"
  end
end
