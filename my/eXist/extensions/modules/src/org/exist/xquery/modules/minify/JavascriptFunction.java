package org.exist.xquery.modules.minify;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.io.Writer;

import org.exist.dom.QName;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.Type;
import org.exist.xquery.Cardinality;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.XPathException;
import org.exist.xquery.value.ValueSequence;
import org.exist.xquery.value.FunctionParameterSequenceType;
import org.exist.xquery.value.FunctionReturnSequenceType;
import org.mozilla.javascript.ErrorReporter;
import org.mozilla.javascript.EvaluatorException;

import com.yahoo.platform.yui.compressor.JavaScriptCompressor;

public class JavascriptFunction extends BasicFunction {

    private final static QName JS_FUNCTION_NAME = new QName("js", MinifyModule.NAMESPACE_URI, MinifyModule.PREFIX);
    private final static String JS_FUNCTION_DESCRIPTION = "Minify Javascript";

    public final static FunctionSignature signature =
		new FunctionSignature(
				JS_FUNCTION_NAME,
				JS_FUNCTION_DESCRIPTION,
				new SequenceType[] { new FunctionParameterSequenceType("js", Type.STRING, Cardinality.ZERO_OR_MORE, "The Javascript files to minify as string values")},
				new FunctionReturnSequenceType(Type.STRING, Cardinality.EXACTLY_ONE, "the minified CSS")
			);
    
	public JavascriptFunction(XQueryContext context) {
		super(context, signature);
	}

	public Sequence eval(Sequence[] args, Sequence contextSequence)
		throws XPathException {

		String css = "test";
		byte[] bytes = null;
		ByteArrayInputStream bais = new ByteArrayInputStream(bytes);
		InputStreamReader isr = new InputStreamReader(bais);
		Writer out = null;
		
		try {
			bytes = css.getBytes("UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		try {
			JavaScriptCompressor compressor = new JavaScriptCompressor(isr, new ErrorReporter(){

                public void warning(String message, String sourceName,
                        int line, String lineSource, int lineOffset) {
                    if (line < 0) {
                        System.err.println("\n[WARNING] " + message);
                    } else {
                        System.err.println("\n[WARNING] " + line + ':' + lineOffset + ':' + message);
                    }
                }

                public void error(String message, String sourceName,
                        int line, String lineSource, int lineOffset) {
                    if (line < 0) {
                        System.err.println("\n[ERROR] " + message);
                    } else {
                        System.err.println("\n[ERROR] " + line + ':' + lineOffset + ':' + message);
                    }
                }

                public EvaluatorException runtimeError(String message, String sourceName,
                        int line, String lineSource, int lineOffset) {
                    error(message, sourceName, line, lineSource, lineOffset);
                    return new EvaluatorException(message);
                }
            });
			compressor.compress(out, 1, false, false, false, false);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		// iterate through the argument sequence and echo each item
		ValueSequence result = new ValueSequence();
		return result;
	}
}