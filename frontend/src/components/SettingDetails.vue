<template>
	<div class="flex flex-col justify-between h-full">
		<div>
			<div class="flex justify-between itemsc-center">
				<div class="mb-1 text-xl font-semibold leading-none">
					{{ __('Метка') }}
				</div>
				<Badge
					v-if="data.isDirty"
					:label="__('Не сохранено')"
					variant="subtle"
					theme="orange"
				/>
			</div>
			<div class="text-xs text-gray-600">
				{{ __('Описание') }}
			</div>
		</div>

		<SettingFields :fields="fields" :data="data.doc" />
		<div class="flex flex-row-reverse mt-auto">
			<Button variant="solid" :loading="data.save.loading" @click="update">
				{{ __('Обновить') }}
			</Button>
		</div>
	</div>
</template>

<script setup>
import SettingFields from '@/components/SettingFields.vue'
import { showToast } from '@/utils'
import { Badge, Button } from 'frappe-ui'

const props = defineProps({
	fields: {
		type: Array,
		required: true,
	},
	data: {
		type: Object,
		required: true,
	},
	label: {
		type: String,
		required: true,
	},
	description: {
		type: String,
	},
})

const update = () => {
	props.fields.forEach((f) => {
		if (f.type != 'Column Break') {
			props.data.doc[f.name] = f.value
		}
	})
	props.data.save.submit(
		{},
		{
			onError(err) {
				showToast(__('Error'), err.messages?.[0] || err, 'x')
			},
		},
	)
}
</script>

<style>
.CodeMirror pre.CodeMirror-line,
.CodeMirror pre.CodeMirror-line-like {
	font-family: revert;
}

.CodeMirror {
	border-radius: 12px;
}
</style>
