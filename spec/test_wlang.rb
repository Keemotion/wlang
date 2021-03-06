require File.expand_path('../spec_helper', __FILE__)
describe WLang do

  it "has a version number" do
    WLang.const_defined?(:VERSION).should be_true
  end

  let(:d){
    WLang::dialect do
      tag('$') do |buf, fn|
        if x = evaluate(fn)
          buf << x.to_s
        end
      end
    end
  }

  it 'allows building on-the-fly dialects' do
    d.render(hello_tpl, :who => "world").should eq("Hello world!")
  end

  ### overriding

  it 'allows overriding super-dialect tags' do
    e = WLang::dialect(d) do
      tag('$') do |buf, fn1|
        buf << render(fn1).capitalize
      end
    end
    e.render(hello_tpl).should eq("Hello Who!")
  end

  it 'allows overriding super-dialect evaluation rules' do
    e = WLang::dialect(d) do
      def evaluate(expr); super rescue ""; end
    end
    e.render(hello_tpl).should eq("Hello !")
  end

  it 'does not override the super-dialect evaluation rules' do
    e = WLang::dialect(d) do
      def evaluate(expr); super rescue ""; end
    end
    lambda{ d.render(hello_tpl) }.should raise_error(NameError)
  end

  ### default scoping

  it 'allows a hash for scoping by default' do
    d.render(hello_tpl, :who => "World").should eq("Hello World!")
  end

  it 'allows binding for scoping by default' do
    who = "World"
    d.render(hello_tpl, binding).should eq("Hello World!")
  end

  ### high-order and multi-dialects

  it 'allows high-order constructions' do
    scope = {:who => :world, :world => "World"}
    d.render('Hello ${${who}}!', scope).should eq("Hello World!")
  end

  it 'allows switching the current dialect' do
    e = WLang::dialect do
      tag '!', [Upcasing] do |buf,fn|
        buf << evaluate(fn).to_s;
      end
    end
    scope = {:WHO => "World"}
    e.render('Hello !{${who}}!', scope).should eq("Hello World!")
  end

  ### autospacing

  it 'handles magic spacing on a static block' do
    e = WLang::dialect do
      default_options :autospacing => true
      tag '$' do |buf,fn| buf << render(fn) end
    end
    source   = "${\n  hello world\n}"
    expected = "hello world"
    pending{
      e.render(source).should eq(expected)
    }
  end

  it 'handles magic spacing on a wlang block' do
    e = WLang::dialect do
      default_options :autospacing => true
      tag '$' do |buf,fn| buf << render(fn) end
    end
    source   = "${\n  ${name}\n  ${score}\n}"
    expected = "name\nscore"
    pending{
      e.render(source).should eq(expected)
    }
  end

end
