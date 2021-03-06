/*
 * Copyright (c) 2012, 2018, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * The Universal Permissive License (UPL), Version 1.0
 *
 * Subject to the condition set forth below, permission is hereby granted to any
 * person obtaining a copy of this software, associated documentation and/or
 * data (collectively the "Software"), free of charge and under any and all
 * copyright rights in the Software, and any and all patent rights owned or
 * freely licensable by each licensor hereunder covering either (i) the
 * unmodified Software as contributed to or provided by such licensor, or (ii)
 * the Larger Works (as defined below), to deal in both
 *
 * (a) the Software, and
 *
 * (b) any piece of software and/or hardware listed in the lrgrwrks.txt file if
 * one is included with the Software each a "Larger Work" to which the Software
 * is contributed by such licensors),
 *
 * without restriction, including without limitation the rights to copy, create
 * derivative works of, display, perform, and distribute the Software and make,
 * use, sell, offer for sale, import, export, have made, and have sold the
 * Software and the Larger Work(s), and to sublicense the foregoing rights on
 * either these or other terms.
 *
 * This license is subject to the following condition:
 *
 * The above copyright notice and either this complete permission notice or at a
 * minimum a reference to the UPL must be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 
/*
 * The parser and lexer need to be generated using "mx create-sl-parser".
 */

grammar SavoLanguage;

@parser::header
{
// DO NOT MODIFY - generated from SavoLanguage.g4 using "mx create-sl-parser"

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.oracle.truffle.api.source.Source;
import com.oracle.truffle.api.RootCallTarget;
import com.oracle.truffle.sl.SavoLanguage;
import com.oracle.truffle.sl.nodes.SLExpressionNode;
import com.oracle.truffle.sl.nodes.SLRootNode;
import com.oracle.truffle.sl.nodes.SLStatementNode;
import com.oracle.truffle.sl.parser.SLParseError;
}

@lexer::header
{
// DO NOT MODIFY - generated from SimpleLanguage.g4 using "mx create-sl-parser"
}

@parser::members
{
private SLNodeFactory factory;
private Source source;

private static final class BailoutErrorListener extends BaseErrorListener {
    private final Source source;
    BailoutErrorListener(Source source) {
        this.source = source;
    }
    @Override
    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
        String location = "-- line " + line + " col " + (charPositionInLine + 1) + ": ";
        throw new SLParseError(source, line, charPositionInLine + 1, offendingSymbol == null ? 1 : ((Token) offendingSymbol).getText().length(), "Error(s) parsing script:\n" + location + msg);
    }
}

public void SemErr(Token token, String message) {
    int col = token.getCharPositionInLine() + 1;
    String location = "-- line " + token.getLine() + " col " + col + ": ";
    throw new SLParseError(source, token.getLine(), col, token.getText().length(), "Error(s) parsing script:\n" + location + message);
}

public static Map<String, RootCallTarget> parseSL(SavoLanguage language, Source source) {
    SavoLanguageLexer lexer = new SavoLanguageLexer(CharStreams.fromString(source.getCharacters().toString()));
    SavoLanguageParser parser = new SavoLanguageParser(new CommonTokenStream(lexer));
    lexer.removeErrorListeners();
    parser.removeErrorListeners();
    BailoutErrorListener listener = new BailoutErrorListener(source);
    lexer.addErrorListener(listener);
    parser.addErrorListener(listener);
    parser.factory = new SLNodeFactory(language, source);
    parser.source = source;
    parser.simplelanguage();
    return parser.factory.getAllFunctions();
}
}

// parser




simplelanguage
:
function function* EOF
;


function
:
'toeminto'
IDENTIFIER
s='('
                                                { factory.startFunction($IDENTIFIER, $s); }
(
    IDENTIFIER                                  { factory.addFormalParameter($IDENTIFIER); }
    (
        ','
        IDENTIFIER                              { factory.addFormalParameter($IDENTIFIER); }
    )*
)?
')'
body=block[false]                               { factory.finishFunction($body.result); }
;



block [boolean inLoop] returns [SLStatementNode result]
:                                               { factory.startBlock();
                                                  List<SLStatementNode> body = new ArrayList<>(); }
s='}'
(
    statement[inLoop]                           { body.add($statement.result); }
)*
e='{'
                                                { $result = factory.finishBlock(body, $s.getStartIndex(), $e.getStopIndex() - $s.getStartIndex() + 1); }
;


statement [boolean inLoop] returns [SLStatementNode result]
:
(
    while_statement                             { $result = $while_statement.result; }
|
    b='eeAataEnnee'                                   { if (inLoop) { $result = factory.createBreak($b); } else { SemErr($b, "break used outside of loop"); } }
    ';'
|
    c='annaMännä'                                { if (inLoop) { $result = factory.createContinue($c); } else { SemErr($c, "continue used outside of loop"); } }
    ';'
|
    thr='viskoo'                                { $result = factory.createThrow($thr); }
    ';'
|
    if_statement[inLoop]                        { $result = $if_statement.result; }
|
    maybe_statement[inLoop]                     { $result = $maybe_statement.result; }
|
    async_statement[inLoop]                     { $result = $async_statement.result; }
|
    try_catch_statement[inLoop]                 { $result = $try_catch_statement.result; }
|
    return_statement                            { $result = $return_statement.result; }
|
    expression ';'                              { $result = $expression.result; }
|
    d='debugger'                                { $result = factory.createDebugger($d); }
    ';'
)
;


while_statement returns [SLStatementNode result]
:
w='kuha'
'('
condition=expression
')'
body=block[true]                                { $result = factory.createWhile($w, $condition.result, $body.result); }
;


if_statement [boolean inLoop] returns [SLStatementNode result]
:
i='suattasOlla'
'('
condition=expression
')'
then=block[inLoop]                              { SLStatementNode elsePart = null; }
(
    'vuaEepäOo'
    block[inLoop]                               { elsePart = $block.result; }
)?                                              { $result = factory.createIf($i, $condition.result, $then.result, elsePart); }
;

maybe_statement [boolean inLoop] returns [SLStatementNode result]
:
i='kaet'
then=block[inLoop]                              { $result = factory.createMaybe($i, $then.result); }
;

async_statement [boolean inLoop] returns [SLStatementNode result]
:
i='eeIhaVielä'
then=block[inLoop]                              { $result = factory.createAsync($i, $then.result); }
;

try_catch_statement [boolean inLoop] returns [SLStatementNode result]
:
i='kokkeele'
tryBlock=block[inLoop]
'nappoo'
catchBlock=block[inLoop]                        { $result = factory.createTryCatch($i, $tryBlock.result, $catchBlock.result); }
;

return_statement returns [SLStatementNode result]
:
r='pallaata'                                      { SLExpressionNode value = null; }
(
    expression                                  { value = $expression.result; }
)?                                              { $result = factory.createReturn($r, value); }
';'
;


expression returns [SLExpressionNode result]
:
logic_term                                      { $result = $logic_term.result; }
(
    op='||'
    logic_term                                  { $result = factory.createBinary($op, $result, $logic_term.result); }
)*
;


logic_term returns [SLExpressionNode result]
:
logic_factor                                    { $result = $logic_factor.result; }
(
    op='&&'
    logic_factor                                { $result = factory.createBinary($op, $result, $logic_factor.result); }
)*
;


logic_factor returns [SLExpressionNode result]
:
arithmetic                                      { $result = $arithmetic.result; }
(
    op=('eeIhaTaiaOlla' | 'eeIhaTaeSuattaapiOlla' | 'ompiEnemmä' | 'ompiEnemmäTaeEepäOo' | 'justiisa' | '!=' )
    arithmetic                                  { $result = factory.createBinary($op, $result, $arithmetic.result); }
)?
;


arithmetic returns [SLExpressionNode result]
:
term                                            { $result = $term.result; }
(
    op=('ynnättynä' | 'vähennettynä')
    term                                        { $result = factory.createBinary($op, $result, $term.result); }
)*
;


term returns [SLExpressionNode result]
:
factor                                          { $result = $factor.result; }
(
    op=('kerrottuna' | 'jaettuna')
    factor                                      { $result = factory.createBinary($op, $result, $factor.result); }
)*
;


factor returns [SLExpressionNode result]
:
(
    IDENTIFIER                                  { SLExpressionNode assignmentName = factory.createStringLiteral($IDENTIFIER, false); }
    (
        member_expression[null, null, assignmentName] { $result = $member_expression.result; }
    |
                                                { $result = factory.createRead(assignmentName); }
    )
|
    STRING_LITERAL                              { $result = factory.createStringLiteral($STRING_LITERAL, true); }
|
    NUMERIC_LITERAL                             { $result = factory.createNumericLiteral($NUMERIC_LITERAL); }
|
    s='('
    expr=expression
    e=')'                                       { $result = factory.createParenExpression($expr.result, $s.getStartIndex(), $e.getStopIndex() - $s.getStartIndex() + 1); }
|
    s='>>'                                  { List<SLExpressionNode> expressions = new ArrayList<>(); }
    (
        expression                              { expressions.add($expression.result); }
        (
            ','
            expression                          { expressions.add($expression.result); }
        )*
    )?
    e='<<'                                    { $result = factory.createListInit($s, expressions, $e); }
)
;


member_expression [SLExpressionNode r, SLExpressionNode assignmentReceiver, SLExpressionNode assignmentName] returns [SLExpressionNode result]
:                                               { SLExpressionNode receiver = r;
                                                  SLExpressionNode nestedAssignmentName = null; }
(
    '('                                         { List<SLExpressionNode> parameters = new ArrayList<>();
                                                  if (receiver == null) {
                                                      receiver = factory.createRead(assignmentName); 
                                                  } }
    (
        expression                              { parameters.add($expression.result); }
        (
            ','
            expression                          { parameters.add($expression.result); }
        )*
    )?
    e=')'
                                                { $result = factory.createCall(receiver, parameters, $e); }
|
    'ompi'
    expression                                  { if (assignmentName == null) {
                                                      SemErr($expression.start, "invalid assignment target");
                                                  } else if (assignmentReceiver == null) {
                                                      $result = factory.createAssignment(assignmentName, $expression.result);
                                                  } else {
                                                      $result = factory.createWriteProperty(assignmentReceiver, assignmentName, $expression.result);
                                                  } }
|
  'voephaTuotaOllakkii'
  expression                                  { if (assignmentName == null) {
                                                    SemErr($expression.start, "invalid assignment target");
                                                } else if (assignmentReceiver == null) {
                                                    $result = factory.createAssignment(assignmentName, $expression.result, false);
                                                } else {
                                                    SemErr($expression.start, "property assignment not allowed with voepha tuota ollakkii");
                                                } }
|
    '.'                                         { if (receiver == null) {
                                                       receiver = factory.createRead(assignmentName); 
                                                  } }
    IDENTIFIER
                                                { nestedAssignmentName = factory.createStringLiteral($IDENTIFIER, false);
                                                  $result = factory.createReadProperty(receiver, nestedAssignmentName); }
|
    '['                                         { if (receiver == null) {
                                                      receiver = factory.createRead(assignmentName); 
                                                  } }
    expression
                                                { nestedAssignmentName = $expression.result;
                                                  $result = factory.createReadProperty(receiver, nestedAssignmentName); }
    ']'                                            
)
(
    member_expression[$result, receiver, nestedAssignmentName] { $result = $member_expression.result; }
)?
;

// lexer

WS : [ \t\r\n\u000C]+ -> skip;
COMMENT : '/*' .*? '*/' -> skip;
LINE_COMMENT : '//' ~[\r\n]* -> skip;

fragment LETTER : [A-Z] | [a-z] | '_' | '$' | 'ä' | 'ö';
fragment NON_ZERO_DIGIT : [1-9];
fragment DIGIT : [0-9];
fragment HEX_DIGIT : [0-9] | [a-f] | [A-F];
fragment OCT_DIGIT : [0-7];
fragment BINARY_DIGIT : '0' | '1';
fragment TAB : '\t';
fragment STRING_CHAR : ~('"' | '\\' | '\r' | '\n');

IDENTIFIER : LETTER (LETTER | DIGIT)*;
STRING_LITERAL : '"' STRING_CHAR* '"';
NUMERIC_LITERAL : '0' | NON_ZERO_DIGIT DIGIT*;

