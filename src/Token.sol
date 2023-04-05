pragma solidity ^0.8.0;
import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract Token is ERC20{
uint256 private _totalSupply = 100000000000 *10 **18; // one Billion
uint256 private _publicPrice = 4500;
uint8 decimal = 18;
bool strategicSalestatus = false;
bool privateSalestatus = false;
bool publicSalestatus = false;
uint256 private strategicSalePrice = 0.030 ether;
uint256 private privateSalePrice = 0.030 ether;
uint256 private publicSalePrice = 0.045 ether;
uint256 private maxStrategicsale = 33500000;
uint256 private maxPrivatesale = 50000000;
uint256 private maxPublicsale = 17000000;
uint256 private StrategicsaleCount;
uint256 private PrivatesaleCount;
uint256 private PublicsaleCount;
address owner;



constructor() ERC20("Test Token", "DRET"){
    owner = msg.sender;
    _mint(msg.sender, 100000 *10 **18);
}
modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }
    function decimals() public view virtual override returns (uint8) {
        return decimal;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function tauntPrice() public view returns(uint256){
        return _publicPrice;
    }
    function strategicSale(uint256 _amount) external payable returns(bool){
        require(msg.sender != address(0), " Invalid Address");
        require(strategicSalestatus == true,"Sale not Started");
        require(_amount < StrategicsaleCount, "Strategic sale count exceeded");
        require(msg.value == _amount * strategicSalePrice, "invalid amount");
        transferFrom(address(this), msg.sender, _amount);
        StrategicsaleCount + _amount;
        return true;
    }
     function privateSale(uint256 _amount) external payable returns(bool){
        require(msg.sender != address(0), " Invalid Address");
        require(privateSalestatus == true,"Sale not Started");
        require(_amount < PrivatesaleCount, "Private sale count exceeded");
        require(msg.value == _amount * privateSalePrice, "invalid amount");
        transferFrom(address(this), msg.sender, _amount);
        PrivatesaleCount + _amount;
        return true;
    }
    function publicSale(uint256 _amount) external payable returns(bool){
        require(msg.sender != address(0), " Invalid Address");
        require(publicSalestatus == true,"Sale not started");
        require(_amount < PublicsaleCount, "Public sale count exceeded");
        require(msg.value == _amount * publicSalePrice, "invalid amount");
        transferFrom(address(this), msg.sender, _amount);
        PublicsaleCount + _amount;
        return true;
    }

}