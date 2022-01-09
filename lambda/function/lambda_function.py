from typing import Dict, Any

def lambda_handler(event: Dict[str, Any], context: Any):
  event_type = event.get("type", "ng")
  if event_type == "ok":
    msg = 'hello world!'
    print(msg)
    return {'result': msg, 'event_type': event_type}
  else:
    raise Exception("raise exception!: {}".format(event_type))
