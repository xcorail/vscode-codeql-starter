import go

class MyDataFlow extends DataFlow::Configuration {
    MyDataFlow() { this = "AuthNCheck" }
    
    override predicate isSource (DataFlow::Node source) {
        source = any(DataFlow::CallNode cn | 
            cn.getTarget().hasQualifiedName("github.com/minio/minio/cmd", "isReqAuthenticated")).getResult()
    }

    override predicate isSink(DataFlow::Node sink) {
        sink = any(DataFlow::EqualityTestNode eqn).getAnOperand()
    }
}

DataFlow::Node getASink() {
    exists(MyDataFlow config, DataFlow::Node sink | config.hasFlow(_, sink) | result = sink)
}

class ErrorCheck extends IfStmt {
    ErrorCheck () {
        this.getCond().(EqualityTestExpr).getAnOperand().(Ident).getName() = "ErrNone"
    }

    BlockStmt getErrorHandlingBranch() {
        if this.getCond() instanceof NeqExpr
        then result = this.getThen()
        else result = this.getElse()
    }

    predicate isCheckingAuthNResult () {
        this.getCond().(EqualityTestExpr).getAnOperand() = getASink().asExpr()
    }
}

from  ErrorCheck ec
where ec.isCheckingAuthNResult() and
    not ec.getErrorHandlingBranch().getAStmt() instanceof ReturnStmt
select ec, "This error check doesn't return."
