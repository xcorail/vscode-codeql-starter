import go

class DataFlowConfig extends DataFlow::Configuration {

    DataFlowConfig() { this = "AuthTest"}

    override predicate isSource (DataFlow::Node source) {
        source = any(DataFlow::CallNode cn | cn.getTarget().hasQualifiedName("github.com/minio/minio/cmd", "isReqAuthenticated")).getResult()
    }

    override predicate isSink(DataFlow::Node sink) {
        sink = any(DataFlow::EqualityTestNode eqn).getAnOperand()
    }
}

class AuthNResultEqualityCheck extends IfStmt {
    AuthNResultEqualityCheck() { 
        exists(DataFlowConfig conf, DataFlow::Node source, DataFlow::Node sink | 
            sink.asExpr() = this.getCond().(EqualityTestExpr).getAnOperand() and conf.hasFlow(source, sink))
    }

    BlockStmt getErrorHandlingBranch() {
        if this.getCond() instanceof NeqExpr
        then result = this.getThen()
        else result = this.getElse()
    }

    predicate isErrorChecking () {
        this.getCond().(EqualityTestExpr).getAnOperand().(Ident).getName() = "ErrNone"
    }
}


from AuthNResultEqualityCheck c
where not c.getErrorHandlingBranch().getAStmt() instanceof ReturnStmt and
    c.isErrorChecking()
select c