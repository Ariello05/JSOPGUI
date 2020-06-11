class Info():
    def __init__(self, name, number):
        self.name = name
        self.number = number


def create_info_args(names):
    return [Info(names[i], i+1)for i in range(0, len(names))]


def map_value(input_value, arg_list):
    for element in arg_list:
        if input_value == element.number:
            return element

    raise Exception("Can't be mapped")


def get_correct_answer(header_info, arg_list):
    answer = ""
    while(answer not in [f"{el.number}" for el in arg_list]):
        print(header_info)
        for item in arg_list:
            print(f"{item.number}.\t{item.name}")
        answer = input("> ")

        if(answer not in [f"{el.number}" for el in arg_list]):
            print(f"Expected input:", end="")
            for item in arg_list:
                print(f"'{item.number}', ", end="")
            print()

    return map_value(int(answer), arg_list)
