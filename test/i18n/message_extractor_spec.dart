library angular2.test.i18n.message_extractor_spec;

import "package:angular2/testing_internal.dart"
    show
        AsyncTestCompleter,
        beforeEach,
        describe,
        ddescribe,
        expect,
        iit,
        inject,
        it,
        xdescribe,
        xit;
import "package:angular2/src/compiler/html_parser.dart" show HtmlParser;
import "package:angular2/src/i18n/message_extractor.dart"
    show MessageExtractor, removeDuplicates;
import "package:angular2/src/i18n/message.dart" show Message;
import "package:angular2/src/compiler/expression_parser/parser.dart"
    show Parser;
import "package:angular2/src/compiler/expression_parser/lexer.dart" show Lexer;

main() {
  describe("MessageExtractor", () {
    MessageExtractor extractor;
    beforeEach(() {
      var htmlParser = new HtmlParser();
      var parser = new Parser(new Lexer());
      extractor = new MessageExtractor(htmlParser, parser);
    });
    it("should extract from elements with the i18n attr", () {
      var res = extractor.extract(
          "<div i18n='meaning|desc'>message</div>", "someurl");
      expect(res.messages).toEqual([new Message("message", "meaning", "desc")]);
    });
    it("should extract from elements with the i18n attr without a desc", () {
      var res =
          extractor.extract("<div i18n='meaning'>message</div>", "someurl");
      expect(res.messages).toEqual([new Message("message", "meaning", null)]);
    });
    it("should extract from elements with the i18n attr without a meaning", () {
      var res = extractor.extract("<div i18n>message</div>", "someurl");
      expect(res.messages).toEqual([new Message("message", null, null)]);
    });
    it("should extract from attributes", () {
      var res = extractor.extract(
          '''
        <div
          title1=\'message1\' i18n-title1=\'meaning1|desc1\'
          title2=\'message2\' i18n-title2=\'meaning2|desc2\'>
        </div>
      ''',
          "someurl");
      expect(res.messages).toEqual([
        new Message("message1", "meaning1", "desc1"),
        new Message("message2", "meaning2", "desc2")
      ]);
    });
    it("should extract from partitions", () {
      var res = extractor.extract(
          '''
         <!-- i18n: meaning1|desc1 -->message1<!-- /i18n -->
         <!-- i18n: meaning2|desc2 -->message2<!-- /i18n -->''',
          "someUrl");
      expect(res.messages).toEqual([
        new Message("message1", "meaning1", "desc1"),
        new Message("message2", "meaning2", "desc2")
      ]);
    });
    it("should ignore other comments", () {
      var res = extractor.extract(
          '''
         <!-- i18n: meaning1|desc1 --><!-- other -->message1<!-- /i18n -->''',
          "someUrl");
      expect(res.messages)
          .toEqual([new Message("message1", "meaning1", "desc1")]);
    });
    it("should replace interpolation with placeholders (text nodes)", () {
      var res = extractor.extract(
          "<div i18n>Hi {{one}} and {{two}}</div>", "someurl");
      expect(res.messages).toEqual([
        new Message(
            "<ph name=\"t0\">Hi <ph name=\"0\"/> and <ph name=\"1\"/></ph>",
            null,
            null)
      ]);
    });
    it("should replace interpolation with placeholders (attributes)", () {
      var res = extractor.extract(
          "<div title='Hi {{one}} and {{two}}' i18n-title></div>", "someurl");
      expect(res.messages).toEqual([
        new Message("Hi <ph name=\"0\"/> and <ph name=\"1\"/>", null, null)
      ]);
    });
    it("should replace interpolation with named placeholders if provided (text nodes)",
        () {
      var res = extractor.extract(
          '''
        <div i18n>Hi {{one //i18n(ph="FIRST")}} and {{two //i18n(ph="SECOND")}}</div>''',
          "someurl");
      expect(res.messages).toEqual([
        new Message(
            "<ph name=\"t0\">Hi <ph name=\"FIRST\"/> and <ph name=\"SECOND\"/></ph>",
            null,
            null)
      ]);
    });
    it("should replace interpolation with named placeholders if provided (attributes)",
        () {
      var res = extractor.extract(
          '''
      <div title=\'Hi {{one //i18n(ph="FIRST")}} and {{two //i18n(ph="SECOND")}}\'
        i18n-title></div>''',
          "someurl");
      expect(res.messages).toEqual([
        new Message(
            "Hi <ph name=\"FIRST\"/> and <ph name=\"SECOND\"/>", null, null)
      ]);
    });
    it("should match named placeholders with extra spacing", () {
      var res = extractor.extract(
          '''
      <div title=\'Hi {{one // i18n ( ph = "FIRST" )}} and {{two // i18n ( ph = "SECOND" )}}\'
        i18n-title></div>''',
          "someurl");
      expect(res.messages).toEqual([
        new Message(
            "Hi <ph name=\"FIRST\"/> and <ph name=\"SECOND\"/>", null, null)
      ]);
    });
    it("should suffix duplicate placeholder names with numbers", () {
      var res = extractor.extract(
          '''
      <div title=\'Hi {{one //i18n(ph="FIRST")}} and {{two //i18n(ph="FIRST")}} and {{three //i18n(ph="FIRST")}}\'
        i18n-title></div>''',
          "someurl");
      expect(res.messages).toEqual([
        new Message(
            "Hi <ph name=\"FIRST\"/> and <ph name=\"FIRST_1\"/> and <ph name=\"FIRST_2\"/>",
            null,
            null)
      ]);
    });
    it("should handle html content", () {
      var res = extractor.extract(
          "<div i18n><div attr=\"value\">zero<div>one</div></div><div>two</div></div>",
          "someurl");
      expect(res.messages).toEqual([
        new Message(
            "<ph name=\"e0\">zero<ph name=\"e2\">one</ph></ph><ph name=\"e4\">two</ph>",
            null,
            null)
      ]);
    });
    it("should handle html content with interpolation", () {
      var res = extractor.extract(
          "<div i18n><div>zero{{a}}<div>{{b}}</div></div></div>", "someurl");
      expect(res.messages).toEqual([
        new Message(
            "<ph name=\"e0\"><ph name=\"t1\">zero<ph name=\"0\"/></ph><ph name=\"e2\"><ph name=\"t3\"><ph name=\"0\"/></ph></ph></ph>",
            null,
            null)
      ]);
    });
    it("should extract from nested elements", () {
      var res = extractor.extract(
          "<div title=\"message1\" i18n-title=\"meaning1|desc1\"><div i18n=\"meaning2|desc2\">message2</div></div>",
          "someurl");
      expect(res.messages).toEqual([
        new Message("message2", "meaning2", "desc2"),
        new Message("message1", "meaning1", "desc1")
      ]);
    });
    it("should extract messages from attributes in i18n blocks", () {
      var res = extractor.extract(
          "<div i18n><div attr=\"value\" i18n-attr=\"meaning|desc\">message</div></div>",
          "someurl");
      expect(res.messages).toEqual([
        new Message("<ph name=\"e0\">message</ph>", null, null),
        new Message("value", "meaning", "desc")
      ]);
    });
    it("should remove duplicate messages", () {
      var res = extractor.extract(
          '''
         <!-- i18n: meaning|desc1 -->message<!-- /i18n -->
         <!-- i18n: meaning|desc2 -->message<!-- /i18n -->''',
          "someUrl");
      expect(removeDuplicates(res.messages))
          .toEqual([new Message("message", "meaning", "desc1")]);
    });
    describe("errors", () {
      it("should error on i18n attributes without matching \"real\" attributes",
          () {
        var res = extractor.extract(
            '''
        <div
          title1=\'message1\' i18n-title1=\'meaning1|desc1\' i18n-title2=\'meaning2|desc2\'>
        </div>
      ''',
            "someurl");
        expect(res.errors.length).toEqual(1);
        expect(res.errors[0].msg).toEqual("Missing attribute 'title2'.");
      });
      it("should error when cannot find a matching desc", () {
        var res = extractor.extract(
            '''
         <!-- i18n: meaning1|desc1 -->message1''',
            "someUrl");
        expect(res.errors.length).toEqual(1);
        expect(res.errors[0].msg).toEqual("Missing closing 'i18n' comment.");
      });
      it("should return parse errors when the template is invalid", () {
        var res = extractor.extract("<input&#Besfs", "someurl");
        expect(res.errors.length).toEqual(1);
        expect(res.errors[0].msg).toEqual("Unexpected character \"s\"");
      });
    });
  });
}