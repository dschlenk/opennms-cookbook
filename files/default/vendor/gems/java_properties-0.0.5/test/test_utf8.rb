require File.dirname(__FILE__) + '/test_helper.rb'

class TestUtf8 < Test::Unit::TestCase

  def test_can_encode_latin
    ascii = 'P'
    assert_equal ascii, JavaProperties::Encoding::Utf8.encode("P")
  end

  def test_can_encode_japanese
    ascii = '\uac00'
    assert_equal ascii, JavaProperties::Encoding::Utf8.encode("\uAC00")
  end
  
  def test_can_decode_latin
    ascii = '\u0050'
    assert_equal "P", JavaProperties::Encoding::Utf8.decode(ascii)
  
  end

  def test_can_decode_japanese
    ascii = '\uac00'
    assert_equal "\uAC00", JavaProperties::Encoding::Utf8.decode(ascii)
  end
  
    

end
