export function createJob(phone?: string) {
  const depositNumber = "44 55";
  const savingsNumber = "33 21";
  const variants = [
    "savings account ending 33 21",
    "Wells Fargo account ending 92 41",
    "Bank of America account ending 48 79",
  ];
  return {
    data: {
      phone,
      depositNumber,
      savingsNumber,
    },
    rpcHandler: {
      async transfer_money(args: any) {
        console.log({ set_args: args });
        const amount: number = Number.parseInt(args.amount);
        if (amount > 800) {
          return false;
        }
        return true;
      },
      async resolve_source_account(args: any) {
        let info: string | { [x: string]: string; }[] = "";
        try {
          console.log({ resolve_source_account_args: JSON.stringify(args) });
          info = args.info;
          if (typeof info !== "string") {
            info = info.reduce((p, c) => `${p}${c.value}`, "");
          }
          if (info === "savings" ||
            info === savingsNumber.replace(/ /g, "")) {
            return `savings account ending ${savingsNumber}`;
          } else if (info === "deposit" ||
            info === depositNumber.replace(/ /g, "")) {
            return `deposit account ending ${depositNumber}`;
          } else {
            throw new Error(JSON.stringify(info));
          }
        } catch (e) {
          console.log({ resolve_source_account_err: e.message });
          return "unknown";
        }
      },
      async resolve_target_account(args: any) {
        let info: string | { [x: string]: string; }[] = "";
        try {
          console.log({ resolve_target_account_args: JSON.stringify(args) });
          info = args.info;
          if (typeof info !== "string") {
            info = info.reduce((p, c) => `${p}${c.value}`, "");
          } else if (info === "wells_fargo") {
            info = "wellsfargo";
          }
          const index = variants
            .map((x) => x.toLowerCase().replace(/ /g, ""))
            .findIndex((x) => x.indexOf(info as string) >= 0);
          if (index < 0) {
            throw new Error(JSON.stringify(info));
          }
          let result = variants[index];
          return result;
        } catch (e) {
          console.log({ resolve_target_account_err: e.message });
          return "unknown";
        }
      },
      async get_target_accounts(args: any) {
        return variants;
      },
    }
  };
}
