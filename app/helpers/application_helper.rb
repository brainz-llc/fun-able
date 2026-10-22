module ApplicationHelper
  # Renders a card's text with each `_____` placeholder replaced by a visual
  # blank. The text is author-supplied, so it is escaped before the (trusted)
  # blank markup is spliced in — `safe_join` escapes every segment and keeps
  # only the separator we built ourselves as HTML.
  def card_content_with_blanks(card, blank_class:)
    segments = card.display_content_with_blanks.to_s.split("_____", -1)
    safe_join(segments, tag.span(nil, class: blank_class))
  end
end
