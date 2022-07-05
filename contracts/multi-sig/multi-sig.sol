// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed signer, uint256 indexed txId);
    event Revoke(address indexed signer, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 createdTime;
        address createdBy;
    }

    address[] public signers; // max array length 255, uint8
    /*
     *   @return array index in signers + 1 when address is signer, otherwise 0
     */
    mapping(address => uint8) public isSigner;
    uint256 public minNumOfApprovals;

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved; // mapping from tx id => signer => bool

    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "MultiSigWallet:txExists: tx does not exist");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "MultiSigWallet:notApproved: tx already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "MultiSigWallet:notExecuted: tx already executed");
        _;
    }

    modifier isFromSigner() {
        require(isSigner[msg.sender], "MultiSigWallet:isFromSigner: only signer allowed");
        _;
    }

    constructor(address[] memory _signers, uint8 _minNumOfApprovals) {
        require(_signers.length > 0, "MultiSigWallet: signers required");
        require(_signers.length < 255, "MultiSigWallet: too many signers");

        require(
            _minNumOfApprovals > 0 && _minNumOfApprovals <= _signers.length,
            "MultiSigWallet: invalid minNumOfApprovals of signers"
        );

        for (uint256 i; i < _signers.length; i++) {
            address signer = _signers[i];

            require(signer != address(0), "MultiSigWallet: invalid signer address");
            require(!isSigner[signer], "MultiSigWallet: duplicated signer");

            isSigner[signer] = i + 1;
            signers.push(signer);
        }

        minNumOfApprovals = _minNumOfApprovals;
    }

    /*
     * @param  _transactionId = array index in transactions
     * @returns  true when the transaction is already executed
     */
    function isTransactionExecuted(uint256 _transactionId) external view txExists returns (bool) {
        return transactions[_transactionId].executed;
    }

    /*
     * @param  _transactionId = array index in transactions
     * @returns  number of approval that the transaction currently got
     */
    function numOfApprovalOfTransaction(uint256 _transactionId) external view txExists returns (uint8) {
        return _numOfApprovalOfTransaction(_transactionId);
    }

    /*
     * @dev  depositing native token
     */
    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /*
     * @dev create a transaction for seek for approval
     */
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes _data
    ) external isFromSigner {
        require(_value >= 0, "MultiSigWallet:submitTransaction: Invalid value");
        transactions.push({to: _to, value: _value, data: _data, createdTime: block.timestamp, createdBy: msg.sender});
        emit Submit(msg.sender, msg.value);
    }

    /*
     * @dev  approving multiple transaction
     */
    function approveMultipleTransaction(uint256[] _transactionIds) external isFromSigner {
        for (uint256 i; i < _transactionIds.length; i++) {
            _approveTransaction(_transactionId);
        }
    }

    /*
     * @dev  approving single transaction
     */
    function approveTransaction(uint256 _transactionId) external isFromSigner {
        _approveTransaction(_transactionId);
    }

    function _approveTransaction(uint256 _transactionId, bool _shouldBroadcast)
        internal
        txExists
        notApproved
        notExecuted
    {
        approved[transactionId][msg.sender] = true;
        emit Approve(msg.sender, msg.value);
        if (_shouldBroadcast) {
            _sendTransaction(_transactionId);
        }
    }

    function triggerMultipleSendTransaction(uint256[] _transactionIds) external isFromSigner {
        for (uint256 i; i < _transactionIds.length; i++) {
            _sendTransaction(_transactionId);
        }
    }

    function triggerSendTransaction(uint256 _transactionId) external isFromSigner {
        _sendTransaction(_transactionId);
    }

    function _sendTransaction(uint256 _transactionId) internal txExists {
        if (numOfApprovalOfTransaction(_transactionId) > minNumOfApprovals) {
            Transaction transaction = transactions[_transactionId];
            (bool sent, ) = payable(this).call{value: transaction.value}(transaction.data);
            require(sent, "MultiSigWallet:approveTransaction: Failed to send Transaction");
            emit Execute(msg.sender, msg.value);
        }
    }

    /*
     * cancel target transaction's approval
     */
    function revokeTransactionApproval(uint256 _transactionId) external isFromSigner txExists notExecuted {
        Transaction transaction = transactions[_transactionId];
        require(approved[transactionId][msg.sender], "MultiSigWallet:revokeTransactionApproval: txn is not approved");
        approved[transactionId][msg.sender] = false;
        emit Revoke(msg.sender, _transactionId);
    }

    function _numOfApprovalOfTransaction(uint256 _transactionId) internal view returns (uint8) {
        uint8 numberOfApproval;
        Transaction transaction = transactions[_transactionId];

        for (uint256 i; i < signers.length; i++) {
            address signer = signers[i];
            bool isApproved = approved[_transactionId][signer];
            if (isApproved) {
                numberOfApproval++;
            }
        }
        return numberOfApproval;
    }
}
