package com.bws.test;

/**
 * 抽象接口和普通接口并无什么区别，只是
 * 为了说明这个接口只是为了继承而生的，
 * 请不要去实现他
 */
public interface ITestInterface {
    void method1();
    int method2();
    boolean method3();
}
abstract class  TestAbstract implements ITestInterface{
    public abstract void method1();
    public abstract int method2();

    public boolean method3(){
        return true;
    }
}
