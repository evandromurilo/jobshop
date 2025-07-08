use "collections"
use "time"

primitive Easy
primitive Avg
primitive Hard
type Job is (Easy | Avg | Hard)
primitive Object

primitive Hammer
primitive Mallet
primitive AnyTool
type ToolQuery is (Hammer | AnyTool)
type ToolType is (Hammer | Mallet)
type OptTool is (ToolType | None)

class ToolRequest
  let who: Jobber tag
  let query: ToolQuery

  new create(who': Jobber tag, query': ToolQuery) =>
    who = who'
    query = query'

  fun matches(tool: ToolType): Bool =>
    (query is AnyTool) or (tool is Hammer)
  
actor Main
  new create(env: Env) =>
    env.out.print("Hello, world!")
    JobShop.create(env)

actor JobShop
  let _tool_queue: List[ToolRequest] = List[ToolRequest]
  let _job_queue: List[Job] = List[Job]
  let _toolbox: List[ToolType] = List[ToolType]
  let _env: Env
  
  new create(env: Env) =>
    _env = env
    _toolbox.push(Mallet)
    _toolbox.push(Hammer)
    _job_queue.push(Hard)
    _job_queue.push(Hard)
    _job_queue.push(Easy)
    _job_queue.push(Hard)
    _job_queue.push(Avg)
    _job_queue.push(Hard)
    _job_queue.push(Hard)
    
    Jobber("John", this)
    Jobber("Mark", this)

  be get_job(who: Jobber tag) =>
    _env.out.print("Someone is looking for work")
    if _job_queue.size() > 0 then
      try
        who.work(_job_queue.shift()?)
      end
    else
      who.no_job()
    end
    
  be get_tool(which: ToolQuery val, who: Jobber tag) =>
    match which
    | AnyTool => _env.out.print("Request for any tool")
    | Hammer => _env.out.print("Request for hammer")
    end
    
    _tool_queue.push(ToolRequest.create(who, which))
    look_queue()

  be put_tool(which: OptTool) =>
    match which
    | Mallet =>_toolbox.push(Mallet)
    | Hammer =>_toolbox.push(Hammer)
    end

    look_queue()

  fun ref look_queue() =>
    for req_node in _tool_queue.nodes() do
      try
        let req: ToolRequest box = req_node.apply()?
        
        for tool_node in _toolbox.nodes() do
          let tool = tool_node.apply()?
          if req.matches(tool) then
            req.who.granted(tool)
            tool_node.remove()
            req_node.remove()
            break
          end
        end
      end
    end

  be out(o: Object) =>
    // TODO tag object with jobber name and job difficulty, and print here
    _env.out.print("Job finished")

  be trash(j: Job) =>
    _env.out.print("Trashed job")

actor Jobber is TimerNotify
  let name: String
  let _shop: JobShop
  var _working_on: (Job | None)
  var _busy: Bool
  var _holding_tool: (ToolType | None)

  new create(name': String, shop': JobShop) =>
    name = name'
    _shop = shop'
    _busy = false
    _working_on = None
    _holding_tool = None
    look_for_job()

  be look_for_job() =>
    if not _busy then
      _shop.get_job(this)
    end

  be work(j: Job) =>
    if _working_on is None then
      _working_on = j
      match j
      | Easy => do_work()
      | Avg => avg_job()
      | Hard => hard_job()
      end
    end
      
  be granted(which: ToolType) =>
    _holding_tool = which
    do_work()

  be skip() =>
    match _working_on
    | let j: Job =>
      _shop.trash(j)
      _working_on = None
      _busy = false
    end

  be no_job() =>
    look_later()

  fun look_later() =>
    let timers = Timers
    let timer = Timer(LookForJob.create(this), 2_000_000_000)
    timers(consume timer)

  fun do_work() =>
    let timers = Timers
    let timer = Timer(DoWork.create(this), 1_000_000_000)
    timers(consume timer)

  be finish_job() =>
    match _holding_tool
    | let t: ToolType =>
      _shop.put_tool(_holding_tool = None)
    end
    
    _working_on = None
    _busy = false
    _shop.out(Object)
    look_later()

  fun ref hard_job() =>
    _shop.get_tool(Hammer, this)

  fun ref avg_job() =>
    _shop.get_tool(AnyTool, this)

class LookForJob is TimerNotify
  let _jobber: Jobber tag

  new iso create(j: Jobber tag) =>
    _jobber = j
  
  fun ref apply(timer: Timer, count: U64): Bool =>
    _jobber.look_for_job()
    false

class DoWork is TimerNotify
  let _jobber: Jobber tag

  new iso create(j: Jobber tag) =>
    _jobber = j
  
  fun ref apply(timer: Timer, count: U64): Bool =>
    _jobber.finish_job()
    false
