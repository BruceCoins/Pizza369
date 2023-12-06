contract Ballot{
	//投票人结构体
    struct Voter{
        uint weight; //权重
        bool voted; //是否已投票默认0
        uint8 vote; //投票给哪个（提案）
        address delegate; //授权给谁（地址），有没有代理
    }

    //被投票的提案
    struct Proposal{
    	//获得了多少票
    	uint voteCount;
    }

    //定义主席，实际就是合约创建者
    address public chairperson;
    //映射，地址=>投票人结构体
    mapping(address=>Voter) voters;
    //可以有多个提案，
    Proposal[] Proposals;

    //初始化，传入参数：提案的个数
    constructor(uint _numberProposals){
    	chairperson = msg.sender; //当前调用者的address赋给主席
    	voters[chairperson].weight = 1; //给主席(即调用者)投票权
    	proposals.length = _numberProposals;
    }

    //主席将投票权利给voter
    function giverRightToVote(address voter) public{
    	if(msg.sender != chairperson || voters[voter].voted) return;
    	voters[voter].weight = 1;
    }

	//代理，当前用户(如：A)将自己的投票权给 to
	function delegate(address to) public{
		//当前委托人sender
		Voter storage sender = voters[msg.sender];
		//当前委托人没有投过票
		if (sender.voted) return;
		//委托是可以传递的，如A委托给 to，to 委托给C
		//如果to也有委托人 C，则to的委托人C的 地址不能是0，且不能是A
		//那么将 A的委托人直接给 C (即to的委托人)
		while(voters[to].delegate != address(0) && voters[to].delegate != msg.sender)
			to = voters[to].delegate;
		//更改投票状态、委托人状态
		sender.voted = true;
		sender.delegate = to;
		//获取被委托人信息
		Voter storage delegateTo = voters[to];
		//如果被委托人已
		if(delegateTo.voted)
			proposals[delegateTo.vote].voteCount += sender.weight;
		else
			delegateTo.weight += sender.weight;
	}

	//投票给toProposal
	function vote(unit8 toProposal) public{
		Voter storage sender voters[msg.sender];
        //判断如果当前用户已投票，或 被投票提案不存在
        if (sender.voted || toProposal >= proposals.length) return;
	    sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight
    }

    //获胜方案
    function winningProposal() public constant returns(uint8 _winningProposal){
        uint256 winningVoteCount = 0;
        for(uint8 prop = 0; prop < proposals.length; prop++)
            if(proposals[prop].voteCount > winningVoteCount){
                winningVoteCount = proposals[prop].voteCount;
                _winningProposal = prop;
            }
    }
}