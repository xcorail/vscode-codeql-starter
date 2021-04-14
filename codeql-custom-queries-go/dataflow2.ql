import go

class CheckErrorCodeAgainstErrNone extends IfStmt {
  CheckErrorCodeAgainstErrNone() {
      this.getCond().(EqualityTestExpr).getAnOperand().(Ident).getName() = "ErrNone"
  }

  BlockStmt getErrorHandlingBranch () {
      if(this.getCond() instanceof NeqExpr)
      then result = this.getThen()
      else result = this.getElse()
  }
}

class AuthTestConfig extends DataFlow::Configuration {

  AuthTestConfig() { this = "auth-test-config" }

  override predicate isSource(DataFlow::Node source) {
    source = any(DataFlow::CallNode cn |
      cn.getTarget().hasQualifiedName("github.com/minio/minio/cmd", "isReqAuthenticated")
    ).getResult()
  }

  override predicate isSink(DataFlow::Node sink) {
    sink = any(DataFlow::EqualityTestNode n).getAnOperand()
  }

}

EqualityTestExpr getAnAuthCheck() {
  exists(AuthTestConfig config, DataFlow::Node sink, DataFlow::EqualityTestNode comparison |
    config.hasFlow(_, sink) and comparison.getAnOperand() = sink |
    result = comparison.asExpr()
  )
}

from CheckErrorCodeAgainstErrNone c
where
c.getCond() = getAnAuthCheck() and
not c.getErrorHandlingBranch().getAStmt() instanceof ReturnStmt
select c