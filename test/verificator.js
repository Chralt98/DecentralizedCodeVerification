const Verificator = artifacts.require("Verificator");
// accounts = web3.eth.getAccounts();
contract('Verificator', (accounts) => {
  it('should add first account as a verified programmer', async () => {
    const verificatorInstance = await Verificator.deployed();
    const programmer = accounts[0];
    await verificatorInstance.addVerifiedProgrammer(programmer).then(async () => {
      const isProgrammerVerified = await verificatorInstance.isProgrammerVerified.call(programmer);
      const programmerPoints = (await verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber();
      assert.equal(isProgrammerVerified, true, "First account is not verified.");
      assert.equal(programmerPoints, 10, "Initial account got not the initial 10 points.");
    });

  });
  it('should do this', async () => {
    const verificatorInstance = await Verificator.deployed();

    // Setup 2 accounts.
    const accountOne = accounts[0];
    const accountTwo = accounts[1];
    // ...
    // send coins => await metaCoinInstance.sendCoin(accountTwo, amount, { from: accountOne });
  });
});
