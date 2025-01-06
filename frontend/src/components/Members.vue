<template>
	<div class="flex flex-col min-h-0 text-base">
		<div class="flex items-center justify-between">
			<div>
				<div class="mb-1 text-xl font-semibold">
					{{ __(label) }}
				</div>
				<!-- <div class="text-xs text-gray-600">
					{{ __(description) }}
				</div> -->
			</div>
			<div class="flex space-x-2 item-center">
				<FormControl
					v-model="search"
					:placeholder="__('Поиск')"
					type="text"
					:debounce="300"
				/>
				<Button @click="() => (showForm = !showForm)">
					<template #icon>
						<Plus v-if="!showForm" class="h-3 w-3 stroke-1.5" />
						<X v-else class="h-3 w-3 stroke-1.5" />
					</template>
				</Button>
			</div>
		</div>

		<!-- Форма для добавления нового участника -->
		<div v-if="showForm" class="flex items-center my-4 space-x-2">
			<FormControl
				v-model="member.email"
				:placeholder="__('Электронная почта')"
				type="email"
				class="w-full"
			/>
			<FormControl
				v-model="member.first_name"
				:placeholder="__('Имя')"
				type="text"
				class="w-full"
			/>
			<Button @click="addMember()" variant="subtle">
				{{ __('Добавить') }}
			</Button>
		</div>

		<div class="pb-10 mt-2 overflow-auto">
			<!-- Список участников -->
			<div class="overflow-y-scroll">
				<ul class="divide-y">
					<li
						v-for="member in memberList"
						class="grid grid-cols-3 gap-10 py-2 cursor-pointer"
					>
						<div
							@click="openProfile(member.username)"
							class="flex items-center col-span-2 space-x-3"
						>
							<Avatar
								:image="member.user_image"
								:label="member.full_name"
								size="lg"
							/>
							<div class="space-y-1">
								<div class="flex">
									<div class="text-gray-900">
										{{ member.full_name }}
									</div>
									<div
										class="px-1"
										v-if="member.role && getRole(member.role) !== 'Student'"
									>
										<Badge
											:variant="'subtle'"
											:ref_for="true"
											theme="blue"
											size="sm"
											label="Badge"
										>
											{{ getRole(member.role) }}
										</Badge>
									</div>
								</div>
								<div class="text-sm text-gray-700">
									{{ member.name }}
								</div>
							</div>
						</div>
						<div class="flex items-center justify-center text-sm text-gray-700">
							<div v-if="member.last_active">
								{{ dayjs(member.last_active).format('DD MMM, YYYY HH:mm a') }}
							</div>
							<div v-else>-</div>
						</div>
					</li>
				</ul>
			</div>
			<div
				v-if="memberList.length && hasNextPage"
				class="flex justify-center mt-4"
			>
				<Button @click="members.reload()">
					<template #prefix>
						<RefreshCw class="h-3 w-3 stroke-1.5" />
					</template>
					{{ __('Загрузить еще') }}
				</Button>
			</div>
		</div>
	</div>
</template>
<script setup lang="ts">
import { Avatar, Badge, Button, createResource, FormControl } from 'frappe-ui'
import { Plus, RefreshCw, X } from 'lucide-vue-next'
import { inject, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const show = defineModel('show')
const search = ref('')
const start = ref(0)
const memberList = ref([])
const hasNextPage = ref(false)
const showForm = ref(false)
const dayjs = inject('$dayjs')

const member = reactive({
	email: '',
	first_name: '',
})

const props = defineProps({
	label: {
		type: String,
		required: true,
	},
	description: {
		type: String,
		default: '',
	},
	show: {
		type: Boolean,
	},
})

const members = createResource({
	url: 'lms.lms.api.get_members',
	makeParams: () => {
		return {
			search: search.value,
			start: start.value,
		}
	},
	onSuccess(data) {
		memberList.value = memberList.value.concat(data)
		start.value = start.value + 20
		hasNextPage.value = data.length === 20
	},
	auto: true,
})

const openProfile = (username) => {
	show.value = false
	router.push({
		name: 'Profile',
		params: {
			username: username,
		},
	})
}

const newMember = createResource({
	url: 'frappe.client.insert',
	makeParams(values) {
		return {
			doc: {
				doctype: 'User',
				first_name: member.first_name,
				email: member.email,
			},
		}
	},
	auto: false,
	onSuccess(data) {
		show.value = false
		router.push({
			name: 'Profile',
			params: {
				username: data.username,
			},
		})
	},
})

const addMember = () => {
	newMember.reload()
}

watch(search, () => {
	memberList.value = []
	start.value = 0
	members.reload()
})

const getRole = (role) => {
	const map = {
		'LMS Student': 'Student',
		'Course Creator': 'Instructor',
		Moderator: 'Moderator',
		'Batch Evaluator': 'Evaluator',
	}
	return map[role]
}
</script>
