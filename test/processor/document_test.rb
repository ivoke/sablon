# -*- coding: utf-8 -*-
require "test_helper"
require "support/document_xml_helper"
require "support/xml_snippets"

class ProcessorDocumentTest < Sablon::TestCase
  include DocumentXMLHelper
  include XMLSnippets

  def setup
    super
    @processor = Sablon::Processor::Document
  end

  def test_simple_field_replacement
    result = process(snippet("simple_field"), {"first_name" => "Jack"})

    assert_equal "Hello! My Name is Jack , nice to meet you.", text(result)
    assert_xml_equal <<-document, result
    <w:p>
      <w:r><w:t xml:space="preserve">Hello! My Name is </w:t></w:r>
        <w:r w:rsidR="004B49F0">
          <w:rPr><w:noProof/></w:rPr>
          <w:t>Jack</w:t>
        </w:r>
      <w:r w:rsidR="00BE47B1"><w:t xml:space="preserve">, nice to meet you.</w:t></w:r>
    </w:p>
    document
  end

  def test_simple_field_replacement_with_nil
    result = process(snippet("simple_field"), {"first_name" => nil})

    assert_equal "Hello! My Name is , nice to meet you.", text(result)
    assert_xml_equal <<-document, result
    <w:p>
      <w:r><w:t xml:space="preserve">Hello! My Name is </w:t></w:r>
      <w:r w:rsidR="00BE47B1"><w:t xml:space="preserve">, nice to meet you.</w:t></w:r>
    </w:p>
    document
  end

  def test_simple_field_with_styling_replacement
    result = process(snippet("simple_field_with_styling"), {"system_name" => "Sablon 1 million"})

    assert_equal "Generated by Sablon 1 million", text(result)
    assert_xml_equal <<-document, result
    <w:p>
      <w:r><w:t xml:space="preserve">Generated by </w:t></w:r>
        <w:r w:rsidR="002D39A9">
          <w:rPr>
            <w:rFonts w:hint="eastAsia"/>
            <w:noProof/>
          </w:rPr>
          <w:t>Sablon 1 million</w:t>
        </w:r>
    </w:p>
    document
  end

  def test_context_can_contain_string_and_symbol_keys
    context = {"first_name" => "Jack", last_name: "Davis"}
    result = process(snippet("simple_fields"), context)
    assert_equal "Jack Davis", text(result)
  end

  def test_complex_field_replacement
    result = process(snippet("complex_field"), {"last_name" => "Zane"})

    assert_equal "Hello! My Name is Zane , nice to meet you.", text(result)
    assert_xml_equal <<-document, result
    <w:p>
      <w:r><w:t xml:space="preserve">Hello! My Name is </w:t></w:r>
      <w:r w:rsidR="004B49F0">
        <w:rPr><w:b/><w:noProof/></w:rPr>
        <w:t>Zane</w:t>
      </w:r>
      <w:r w:rsidR="00BE47B1"><w:t xml:space="preserve">, nice to meet you.</w:t></w:r>
    </w:p>
    document
  end

  def test_complex_field_replacement_with_split_field
    result = process(snippet("edited_complex_field"), {"first_name" => "Daniel"})

    assert_equal "Hello! My Name is Daniel , nice to meet you.", text(result)
    assert_xml_equal <<-document, result
    <w:p>
      <w:r><w:t xml:space="preserve">Hello! My Name is </w:t></w:r>
      <w:r w:rsidR="00441382">
        <w:rPr><w:noProof/></w:rPr>
        <w:t>Daniel</w:t>
      </w:r>
      <w:r w:rsidR="00BE47B1"><w:t xml:space="preserve">, nice to meet you.</w:t></w:r>
    </w:p>
    document
  end

  def test_paragraph_block_replacement
    result = process(snippet("paragraph_loop"), {"technologies" => ["Ruby", "Rails"]})

    assert_equal "Ruby Rails", text(result)
    assert_xml_equal <<-document, result
      <w:p w14:paraId="1081E316" w14:textId="3EAB5FDC" w:rsidR="00380EE8" w:rsidRDefault="00380EE8" w:rsidP="007F5CDE">
         <w:pPr>
            <w:pStyle w:val="ListParagraph"/>
            <w:numPr>
               <w:ilvl w:val="0"/>
               <w:numId w:val="1"/>
            </w:numPr>
         </w:pPr>
         <w:r w:rsidR="009F01DA">
            <w:rPr><w:noProof/></w:rPr>
            <w:t>Ruby</w:t>
         </w:r>
      </w:p><w:p w14:paraId="1081E316" w14:textId="3EAB5FDC" w:rsidR="00380EE8" w:rsidRDefault="00380EE8" w:rsidP="007F5CDE">
         <w:pPr>
            <w:pStyle w:val="ListParagraph"/>
            <w:numPr>
               <w:ilvl w:val="0"/>
               <w:numId w:val="1"/>
            </w:numPr>
         </w:pPr>
         <w:r w:rsidR="009F01DA">
            <w:rPr><w:noProof/></w:rPr>
            <w:t>Rails</w:t>
         </w:r>
      </w:p>
    document
  end

  def test_paragraph_block_within_table_cell
    result = process(snippet("paragraph_loop_within_table_cell"), {"technologies" => ["Puppet", "Chef"]})

    assert_equal "Puppet Chef", text(result)
    assert_xml_equal <<-document, result
    <w:tbl>
      <w:tblGrid>
        <w:gridCol w:w="2202"/>
      </w:tblGrid>
      <w:tr w:rsidR="00757DAD">
        <w:tc>
          <w:p>
            <w:r w:rsidR="004B49F0">
              <w:rPr><w:noProof/></w:rPr>
              <w:t>Puppet</w:t>
            </w:r>
          </w:p>
          <w:p>
            <w:r w:rsidR="004B49F0">
              <w:rPr><w:noProof/></w:rPr>
              <w:t>Chef</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
    </w:tbl>
    document
  end

  def test_paragraph_block_within_empty_table_cell_and_blank_replacement
    result = process(snippet("paragraph_loop_within_table_cell"), {"technologies" => []})

    assert_equal "", text(result)
    assert_xml_equal <<-document, result
    <w:tbl>
      <w:tblGrid>
        <w:gridCol w:w="2202"/>
      </w:tblGrid>
      <w:tr w:rsidR="00757DAD">
        <w:tc>
          <w:p></w:p>
        </w:tc>
      </w:tr>
    </w:tbl>
    document
  end

  def test_adds_blank_paragraph_to_empty_table_cells
    result = process(snippet("corrupt_table"), {})
    assert_xml_equal <<-document, result
<w:tbl>
  <w:tblGrid>
    <w:gridCol w:w="2202"/>
  </w:tblGrid>
  <w:tr w:rsidR="00757DAD">
    <w:tc>
      <w:p>
        Hans
      </w:p>
    </w:tc>

    <w:tc>
      <w:tcPr>
        <w:tcW w:w="5635" w:type="dxa"/>
      </w:tcPr>
      <w:p></w:p>
    </w:tc>
  </w:tr>

  <w:tr w:rsidR="00757DAD">
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="2202" w:type="dxa"/>
      </w:tcPr>
      <w:p>
        <w:r>
          <w:rPr><w:noProof/></w:rPr>
          <w:t>1.</w:t>
        </w:r>
      </w:p>
    </w:tc>

    <w:tc>
      <w:p>
        </w:p><w:p>
        <w:r w:rsidR="004B49F0">
          <w:rPr><w:noProof/></w:rPr>
          <w:t>Chef</w:t>
        </w:r>
      </w:p>
    </w:tc>
  </w:tr>
</w:tbl>
    document
  end

  def test_single_row_table_loop
    item = Struct.new(:index, :label, :rating)
    result = process(snippet("table_row_loop"), {"items" => [item.new("1.", "Milk", "***"), item.new("2.", "Sugar", "**")]})

    assert_xml_equal <<-document, result
    <w:tbl>
      <w:tblPr>
        <w:tblStyle w:val="TableGrid"/>
        <w:tblW w:w="0" w:type="auto"/>
        <w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="0" w:noVBand="1"/>
      </w:tblPr>
      <w:tblGrid>
        <w:gridCol w:w="2202"/>
        <w:gridCol w:w="4285"/>
        <w:gridCol w:w="2029"/>
      </w:tblGrid>
      <w:tr w:rsidR="00757DAD" w14:paraId="1BD2E50A" w14:textId="77777777" w:rsidTr="006333C3">
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="2202" w:type="dxa"/>
          </w:tcPr>
          <w:p w14:paraId="41ACB3D9" w14:textId="77777777" w:rsidR="00757DAD" w:rsidRDefault="00757DAD" w:rsidP="006333C3">
            <w:r>
              <w:rPr><w:noProof/></w:rPr>
              <w:t>1.</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="4285" w:type="dxa"/>
          </w:tcPr>
          <w:p w14:paraId="197C6F31" w14:textId="77777777" w:rsidR="00757DAD" w:rsidRDefault="00757DAD" w:rsidP="006333C3">
            <w:r>
              <w:rPr><w:noProof/></w:rPr>
              <w:t>Milk</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="2029" w:type="dxa"/>
          </w:tcPr>
          <w:p w14:paraId="55C258BB" w14:textId="77777777" w:rsidR="00757DAD" w:rsidRDefault="00757DAD" w:rsidP="006333C3">
            <w:r>
              <w:rPr><w:noProof/></w:rPr>
              <w:t>***</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr><w:tr w:rsidR="00757DAD" w14:paraId="1BD2E50A" w14:textId="77777777" w:rsidTr="006333C3">
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="2202" w:type="dxa"/>
          </w:tcPr>
          <w:p w14:paraId="41ACB3D9" w14:textId="77777777" w:rsidR="00757DAD" w:rsidRDefault="00757DAD" w:rsidP="006333C3">
            <w:r>
              <w:rPr><w:noProof/></w:rPr>
              <w:t>2.</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="4285" w:type="dxa"/>
          </w:tcPr>
          <w:p w14:paraId="197C6F31" w14:textId="77777777" w:rsidR="00757DAD" w:rsidRDefault="00757DAD" w:rsidP="006333C3">
            <w:r>
              <w:rPr><w:noProof/></w:rPr>
              <w:t>Sugar</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="2029" w:type="dxa"/>
          </w:tcPr>
          <w:p w14:paraId="55C258BB" w14:textId="77777777" w:rsidR="00757DAD" w:rsidRDefault="00757DAD" w:rsidP="006333C3">
            <w:r>
              <w:rPr><w:noProof/></w:rPr>
              <w:t>**</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
    </w:tbl>

    document
  end

  def test_loop_over_collection_convertable_to_an_enumerable
    style_collection = Class.new do
      def to_ary
        ["CSS", "SCSS", "LESS"]
      end
    end

    result = process(snippet("paragraph_loop"), {"technologies" => style_collection.new})
    assert_equal "CSS SCSS LESS", text(result)
  end

  def test_loop_over_collection_not_convertable_to_an_enumerable_raises_error
    not_a_collection = Class.new {}

    assert_raises Sablon::ContextError do
      process(snippet("paragraph_loop"), {"technologies" => not_a_collection.new})
    end
  end

  def test_loop_with_missing_variable_raises_error
    e = assert_raises Sablon::ContextError do
      process(snippet("paragraph_loop"), {})
    end
    assert_equal "The expression «technologies» should evaluate to an enumerable but was: nil", e.message
  end

  def test_loop_with_missing_end_raises_error
    e = assert_raises Sablon::TemplateError do
      process(snippet("loop_without_ending"), {})
    end
    assert_equal "Could not find end field for «technologies:each(technology)». Was looking for «technologies:endEach»", e.message
  end

  def test_conditional_with_missing_end_raises_error
    e = assert_raises Sablon::TemplateError do
      process(snippet("conditional_without_ending"), {})
    end
    assert_equal "Could not find end field for «middle_name:if». Was looking for «middle_name:endIf»", e.message
  end

  def test_multi_row_table_loop
    item = Struct.new(:index, :label, :body)
    context = {"foods" => [item.new("1.", "Milk", "Milk is a white liquid."),
                           item.new("2.", "Sugar", "Sugar is the generalized name for carbohydrates.")]}
    result = process(snippet("table_multi_row_loop"), context)

    assert_equal "1. Milk Milk is a white liquid. 2. Sugar Sugar is the generalized name for carbohydrates.", text(result)
  end

  def test_conditional
    result = process(snippet("conditional"), {"middle_name" => "Michael"})
    assert_equal "Anthony Michael Hall", text(result)

    result = process(snippet("conditional"), {"middle_name" => nil})
    assert_equal "Anthony Hall", text(result)
  end

  def test_simple_field_conditional_inline
    result = process(snippet("conditional_inline"), {"middle_name" => true})
    assert_equal "Anthony Michael Hall", text(result)
  end

  def test_complex_field_conditional_inline
    with_false = process(snippet("complex_field_inline_conditional"), {"boolean" => false})
    assert_equal "ParagraphBefore Before After ParagraphAfter", text(with_false)

    with_true = process(snippet("complex_field_inline_conditional"), {"boolean" => true})
    assert_equal "ParagraphBefore Before Content After ParagraphAfter", text(with_true)
  end

  def test_ignore_complex_field_spanning_multiple_paragraphs
    result = process(snippet("test_ignore_complex_field_spanning_multiple_paragraphs"),
                     {"current_time" => '14:53'})

    assert_equal "AUTOTEXT Header:Date \\* MERGEFORMAT Day Month Year 14:53", text(result)
    assert_xml_equal <<-document, result
    <w:p w14:paraId="2A8BFD66" w14:textId="77777777" w:rsidR="006F0A69" w:rsidRDefault="00E40CBA" w:rsidP="00670731">
      <w:r>
        <w:fldChar w:fldCharType="begin"/>
      </w:r>
      <w:r>
        <w:instrText xml:space="preserve"> AUTOTEXT  Header:Date  \\* MERGEFORMAT </w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="separate"/>
      </w:r>
      <w:r w:rsidR="006F0A69" w:rsidRPr="009A09E3">
        <w:t>Day Month Year</w:t>
      </w:r>
    </w:p>

    <w:p w14:paraId="71B65E52" w14:textId="613138CB" w:rsidR="001D1AF8" w:rsidRDefault="00E40CBA" w:rsidP="006C34C3">
      <w:pPr>
        <w:pStyle w:val="Address"/>
      </w:pPr>
      <w:r>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
      <w:bookmarkEnd w:id="0"/>
    </w:p>

    <w:p w14:paraId="7C3EB778" w14:textId="78AB4714" w:rsidR="001D1AF8" w:rsidRPr="000C6261" w:rsidRDefault="00A35B65" w:rsidP="001D1AF8">
        <w:r>
          <w:rPr>
            <w:noProof/>
          </w:rPr>
          <w:t>14:53</w:t>
        </w:r>
    </w:p>
    document
  end

  def test_conditional_with_predicate
    result = process(snippet("conditional_with_predicate"), {"body" => ""})
    assert_equal "some content", text(result)

    result = process(snippet("conditional_with_predicate"), {"body" => "not empty"})
    assert_equal "", text(result)
  end

  def test_conditional_with_equality_operator
    result = process(snippet("conditional_with_equality_operator"), {"middle_name" => "John", "age" => 45})  
    assert_xml_equal <<-document, result
        <w:p>
          <w:t>some content</w:t>
        </w:p>
        <w:p>
          <w:t>some content</w:t>
        </w:p>
    document
  end

  def test_comment
    result = process(snippet("comment"), {})
    assert_equal "Before After", text(result)
  end

  def test_comment_block_and_comment_as_key
    result = process(snippet("comment_block_and_comment_as_key"), {comment: 'Contents of comment key'})

    assert_xml_equal <<-document, result
    <w:r><w:t xml:space="preserve">Before </w:t></w:r>
    <w:r><w:t xml:space="preserve">After </w:t></w:r>
    <w:p>           
      <w:r w:rsidR="004B49F0">
        <w:rPr><w:noProof/></w:rPr>
        <w:t>Contents of comment key</w:t>
      </w:r>
    </w:p>
    document
  end

  private

  def process(document, context)
    env = Sablon::Environment.new(nil, context)
    @processor.process(wrap(document), env).to_xml
  end
end
