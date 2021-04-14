import go

// Data flow configuration boilerplate
class MyDataFlowConfig extends DataFlow::Configuration {

    MyDataFlowConfig() { this = "my-config-name" }
  
    override predicate isSource(DataFlow::Node source) {
      source = any(DataFlow::CallNode cn | cn.getTarget().hasQualifiedName("github.com/minio/minio/cmd", "isReqAuthenticated")).getResult()
    }
  
    override predicate isSink(DataFlow::Node sink) {
      sink = any(DataFlow::EqualityTestNode eqn).getAnOperand()
    }
  
  }

  // package, function
  // "github.com/minio/minio/cmd", "isReqAuthenticated"

  // predicate isAuthN () {
  //   exists(MyDataFlowConfig config, DataFlow::Node sink | 
  //       config.hasFlow(_, sink) | 
  //       sink.asExpr() = this.getCond().(EqualityTestExpr).getAnOperand())    
  // }
